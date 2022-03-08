include("SSets.jl")

N = 10

for i in 2:N
    m = elements(repeat1d(i))
    write_json_acset(m, string("meshes/mesh", 2, "x", i, ".json"))
end