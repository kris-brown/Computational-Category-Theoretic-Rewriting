import json
import os
import gc
import timeit
from regraph import NXGraph

def import_catlab_graph(fpath):
    f = open(fpath)
    data = json.load(f)

    g = NXGraph()

    # Add nodes
    for node, num in list(zip(data['El'], range(len(data['El'])))):
        g.add_node('n'+str(num), {'type': data['Ob'][node['πₑ']-1]['nameo']})

    # Add edges
    for edge in data['Arr']:
        src = 'n'+str(edge['src']-1)
        tgt = 'n'+str(edge['tgt']-1)
        typ = data['Hom'][edge['πₐ']-1]['nameh']
        g.add_edge(src, tgt, {'type': typ})

    return g

# Print a list of nodes and edges with data attached to them
def print_graph(g):
    print("List of nodes: ")
    for n, attrs in g.nodes(data=True):
        print("\t", n, attrs)
    print("List of edges: ")
    for s, t, attrs in g.edges(data=True):
        print("\t{}->{}".format(s, t), attrs)

def match(mesh, pattern):
    return mesh.find_matching(pattern)

if __name__ == '__main__':
    mesh_path = '../meshes/'
    mesh_files = os.listdir(mesh_path)
    quad = import_catlab_graph(mesh_path + 'mesh2x2.json')
    mesh2x2 = quad
    mesh2x3 = import_catlab_graph(mesh_path + 'mesh2x3.json')
    mesh2x4 = import_catlab_graph(mesh_path + 'mesh2x4.json')
    mesh2x5 = import_catlab_graph(mesh_path + 'mesh2x5.json')

    duration = timeit.timeit('match(mesh2x2, quad)', setup="gc.enable(); from __main__ import match", number = 1, globals=globals())
    print(duration)
    duration = timeit.timeit('match(mesh2x3, quad)', setup="gc.enable(); from __main__ import match", number = 1, globals=globals())
    print(duration)
    duration = timeit.timeit('match(mesh2x4, quad)', setup="gc.enable(); from __main__ import match", number = 1, globals=globals())
    print(duration)
    duration = timeit.timeit('match(mesh2x5, quad)', setup="gc.enable(); from __main__ import match", number = 1, globals=globals())
    print(duration)
