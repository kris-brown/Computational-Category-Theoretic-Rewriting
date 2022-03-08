using Catlab.Graphs
using Catlab.CategoricalAlgebra
using Catlab.Present
using DataFrames
using CSV

include("SSets.jl")

""" Homomorphisms Benchmark """

# Run every hom up to N1 then every 5 up to N2
function homomorphisms_benchmark(N1::Int,N2::Int)
  elQuad = elements(quad)
  sizes = vcat(2,2:N1,N1+5:5:N2)
  reps = 5
  times = Vector{Float64}[]
  eltimes = Vector{Float64}[]
  for i in sizes
    push!(times, Float64[])
    push!(eltimes, Float64[])
    G = repeat1d(i)
    elG = elements(G)
    for _ in 1:reps
      Base.GC.gc(false)
      push!(times[end], @timed(homomorphisms(quad, G))[2])
      println("Finding all quads in 2x$i mesh: $(times[end][end]) seconds")
      Base.GC.gc(false)
      push!(eltimes[end], @timed(homomorphisms(elQuad, elG))[2])
      println("Finding all quads in 2x$i elements mesh: $(eltimes[end][end]) seconds")
    end
  end

  avg_times = [sum(v[2:end])/(reps-1) for v in times[2:end]]
  avg_eltimes = [sum(v[2:end])/(reps-1) for v in eltimes[2:end]]
  data = DataFrame(:n=>sizes[2:end], :Times=>avg_times, :ElTimes=>avg_eltimes)
  return data
end

function write_hom_benchmark(data)
  CSV.write("hom_benchmark_data.csv", data)
end

""" Internal Rewrite Benchmark """

function internal_benchmark(N::Int)
  # Define rewrite rule
  R = homomorphism(quad_int, quad_repl; initial=Dict([:V=>[1,2,3,4]]))
  L = homomorphism(quad_int, quad; initial=Dict([:V=>[1,2,3,4]]))
  gR, gL = elements.([R,L])

  # Run rewrites of increasing size for each

  times, Gtimes = Vector{Float64}[], Vector{Float64}[]
  sizes = vcat(2,2:N)
  reps = 5
  for i in sizes
    push!(times, Float64[]);push!(Gtimes, Float64[]);
    G = repeat(i)
    m = homomorphism(codom(L), G)
    gm = elements(m)
    for _ in 1:reps
      Base.GC.gc(false)
      push!(times[end], @timed(rewrite_match(L,R,m))[2])
      println("$(i)x$i mesh rewrite: $(times[end][end]) seconds")
      Base.GC.gc(false)
      push!(Gtimes[end], @timed(rewrite_match(gL,gR,gm))[2])
      println("$(i)x$i graph mesh rewrite: $(Gtimes[end][end]) seconds\n")
    end
  end

  # drop smallest one due to compilation
  pTimes, pGtimes = [[sum(v[2:end])/(reps-1) for v in vs ]
                          for vs in [times, Gtimes]]

  # Write benchmarking data to CSV
  data = DataFrame(:n=>collect(2:N), :Times=>pTimes[2:end], :GTimes=>pGtimes[2:end])
  #CSV.write("benchmark_data.csv", data)

  #get memory footprint of cset and typed graph representations
  cset_sizes = Float64[]
  for i in 2:N
    push!(cset_sizes, Base.summarysize(repeat(i)))
  end

  graph_sizes = Float64[]
  for i in 2:N
    push!(graph_sizes, Base.summarysize(elements(repeat(i))))
  end

  size_data = DataFrame(:n=>collect(2:N), :cset_sizes=>cset_sizes, :graph_sizes=>graph_sizes)
  #CSV.write("size_data.csv", size_data)
  return data,size_data
end

function write_data(data,size_data)
  CSV.write("size_data.csv", size_data)
  CSV.write("benchmark_data.csv", data)
end
