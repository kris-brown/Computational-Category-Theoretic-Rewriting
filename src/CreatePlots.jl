using Plots
using Plots.PlotMeasures
using CSV
using DataFrames
using LaTeXStrings
theme(:ggplot2)

df = CSV.read("benchmark_data.csv", DataFrame)

pTimes = df.Times
pGtimes = df.GTimes
sizes = df.n
num_triangles = map(x->2*(x-1)^2,sizes)

f = "Computer Modern"

size_data = CSV.read("size_data.csv", DataFrame)
cset_sizes = size_data.cset_sizes
graph_sizes = size_data.graph_sizes

normalized_times = pTimes ./ cset_sizes
normalized_gtimes = pGtimes ./ graph_sizes

hom_df = CSV.read("hom_benchmark_data.csv", DataFrame)
sizes = hom_df.n
times = hom_df.Times
el_times = hom_df.ElTimes

p1 = scatter(num_triangles, pGtimes,
    size = (1000,800),
    #markershape = :vline, ms=5,
    title="Rewrite Performance",
    #titlefont = (15,f),
    titlefont = f, titlefontsize = 15,
    linewidth = 2,
    label= "Typed graphs", 
    ylabel="Time (s)", 
    xlabel="Number of triangles in grid",
    thickness_scaling = 2,
    xticks = ([0:5000:20000;],["2","5k","10k","15k","20k"]),
    #tickfont = (12, f),
    tickfont = f, tickfontsize = 12,
    legend = :topleft,
    #legendfont = Plots.Font(f, 20, :hcenter, :vcenter, 0.0, RGB(0.0,0.0,0.0)),
    legend_font_family = f,
    smooth = true,
    legendfontsize = 15,
    seriescolor=palette(:default)[2],
    ms=4,
    #guidefont = (f,15)
    guidefont = f, guidefontsize = 15,
    bottom_margin=5mm
)
scatter!(num_triangles, pTimes, 
    label="C-sets", linewidth=2, 
    seriescolor=palette(:default)[1], smooth = true, ms=4
)
#plot!(num_triangles, pGtimes, smooth = true, linewidth=2, #=markershape=:circle, ms=4,=# label="", seriescolor=palette(:default)[2])
#plot!(num_triangles, pTimes, smooth = true, label="", linewidth=2, #=markershape=:rect, ms=4,=# seriescolor=palette(:default)[1])

p2 = scatter(num_triangles, graph_sizes,
    size = (1000,800),
    #markershape = :vline, ms=5,
    ms=4,
    title="Memory Usage",
    #titlefont = (15,f),
    titlefont = f,
    titlefontsize = 15,
    linewidth = 2,
    label="Typed graphs", 
    ylabel="Memory usage (Mb)", 
    xlabel="Number of triangles in grid",
    thickness_scaling = 2,
    xticks = ([0:5000:20000;],["2","5k","10k","15k","20k"]),
    yticks = ([0:2e6:1.2e7;],["0","2","4","6","8","10","12"]),
    tickfont = f, tickfontsize = 12,
    legend = :topleft,
    #legendfont = Plots.Font(f, 20, :hcenter, :vcenter, 0.0, RGB(0.0,0.0,0.0)),
    legend_font_family = f,
    legendfontsize = 15,
    seriescolor=palette(:default)[2],
    bottom_margin=5mm,
    guidefont = f, guidefontsize = 15,
    smooth=true
)
scatter!(num_triangles, cset_sizes, 
    label="C-sets", linewidth=2, 
    seriescolor=palette(:default)[1],
    ms=4,
    smooth=true
)

#num_triangles = map(x->(x-1)*2, sizes)
num_triangles = sizes.*2

function log_func(x0,x1,y0,y1)
    return x->y0*(x/x0)^(log10(y1/y0)/log10(x1/x0))
end

p3 = scatter(#vcat(sizes[1:5:49],sizes[49:end]), vcat(times[1:5:49],times[49:end]),
    num_triangles,el_times,
    size = (1000,800),
    #markershape = :vline, ms=5,
    title="Homomorphisms Performance",
    xticks=[10^1,10^1.5,10^2, 10^2.5],
    yticks=[1e-4,1e-3,1e-2,1e-1,1e0,1e1,1e2],
    minorgrid=false,
    minorticks=0,
    #titlefont = (15,f),
    titlefont = f, titlefontsize = 15,
    linewidth = 2,
    label= "Typed graphs", 
    ylabel="Time (s)", 
    xlabel="Number of triangles in grid",
    thickness_scaling = 2,
    #xticks = ([0:5000:20000;],["2","5k","10k","15k","20k"]),
    #tickfont = (12, f),
    tickfont = f, tickfontsize = 12,
    legend = :topleft,
    #legendfont = Plots.Font(f, 20, :hcenter, :vcenter, 0.0, RGB(0.0,0.0,0.0)),
    legend_font_family = f,
    #smooth = true,
    legendfontsize = 13,
    seriescolor=palette(:default)[2],
    ms=4,
    #guidefont = (f,15)
    guidefont = f, guidefontsize = 15,
    yscale = :log10, xscale = :log10,
    bottom_margin=7mm
)
scatter!(#vcat(sizes[1:5:20],sizes[49:end]), vcat(el_times[1:5:49],el_times[49:end]), 
    num_triangles,times,
    label="C-sets", linewidth=2, 
    seriescolor=palette(:default)[1], #=smooth = true,=# ms=4, 
    yscale=:log10, xscale = :log10
)

# Fit lines to data
tg_trend = log_func(num_triangles[end-7], num_triangles[end], el_times[end-7], el_times[end])
tg_ys = map(tg_trend, num_triangles)
plot!(num_triangles, tg_ys, xscale=:log10, yscale=:log10,
    label="", linewidth=2,
    seriescolor=palette(:default)[2]
)

trend = log_func(num_triangles[end-7], num_triangles[end], times[end-7], times[end])
ys = map(trend, num_triangles)
plot!(num_triangles, ys, xscale=:log10, yscale=:log10,
    label="", linewidth=2,
    seriescolor=palette(:default)[1]
)

l = @layout [a b c]
#plot(p1, p2, p3, layout=l, size=(3000,800))
p = plot(p1,p3,p2, layout=l, size=(3000,800))
png(p, "Bench_Plot.png")
#=regraph_data = [0.00526,8.0475,1313.32,44979.8]
p4 = scatter(sizes[1:4], times[1:4],
    yscale=:log10, xscale=:log10
)
scatter!(sizes[1:4], regraph_data,
    yscale=:log10, xscale=:log10    
)=#
