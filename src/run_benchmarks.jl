include("RewritingBenchmark.jl")

N1=50
N2=80
N3=80

write_hom_benchmark(homomorphisms_benchmark(N1,N2))
data,size_data = internal_benchmark(N3)
write_data(data,size_data)