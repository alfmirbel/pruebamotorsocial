import os
import math
import sys

matplotlib = __import__('matplotlib')
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patheffects as pe
from matplotlib.patches import FancyBboxPatch

OUT_REL = 'agent_dependency_graph.svg'

out = os.path.join('docs', OUT_REL)

nodes = {
    'A': dict(label='MotorSocial\nBridgeNotifier', kind='orchestrator', idx=(0, 0)),
    'A1': dict(label='MotorSocial\nBridge', kind='orchestrator', idx=(2, 0)),
    'B': dict(label='SocialIdentity\nEngine', kind='domain', idx=(0, -2)),
    'C': dict(label='Catalog\nEngine', kind='domain', idx=(3, -2)),
    'D': dict(label='SocialGraph\nEngine', kind='domain', idx=(6, -2)),
    'E': dict(label='Activity\nEngine', kind='domain', idx=(9, -2)),
    'F': dict(label='Design\nEngine', kind='domain', idx=(12, -2)),
    'G': dict(label='Location\nEngine', kind='domain', idx=(0, -4)),
    'H': dict(label='Media\nEngine', kind='domain', idx=(3, -4)),
    'I': dict(label='Security\nEngine', kind='domain', idx=(9, -4)),
    'J': dict(label='Database\nModule', kind='persistence', idx=(12, -4)),
    'B1': dict(label='Auth\nRepository', kind='repo', idx=(-1, -3)),
    'B2': dict(label='Session\nRepository', kind='repo', idx=(1, -3)),
    'C1': dict(label='Catalog\nRepository', kind='repo', idx=(2, -3)),
    'C2': dict(label='Activity\nRepository', kind='repo', idx=(4, -3)),
    'D1': dict(label='Relationship\nRepository', kind='repo', idx=(5, -3)),
    'D2': dict(label='Invitation\nRepository', kind='repo', idx=(7, -3)),
    'D3': dict(label='Group\nRepository', kind='repo', idx=(7, -4)),
    'E1': dict(label='DirectMessage\nRepository', kind='repo', idx=(8, -3)),
    'E2': dict(label='Reaction\nRepository', kind='repo', idx=(9, -3)),
    'E3': dict(label='Share\nRepository', kind='repo', idx=(10, -3)),
    'F1': dict(label='Theme\nRepository', kind='repo', idx=(12, -3)),
    'G1': dict(label='Geolocation\nRepository', kind='repo', idx=(-1, -5)),
    'G2': dict(label='PostalCode\nRepository', kind='repo', idx=(1, -5)),
    'H1': dict(label='Media\nRepository', kind='repo', idx=(3, -4.5)),
    'I1': dict(label='Security\nRepository', kind='repo', idx=(10, -4.5)),
    'J1': dict(label='CouchDB\nRepository', kind='repo', idx=(12, -5.5)),
    'J2': dict(label='Qdrant\nRepository', kind='repo', idx=(14, -5.5)),
}

edges = [
    ('A', 'A1'),
    ('A1', 'B'),
    ('A1', 'C'),
    ('A1', 'D'),
    ('A1', 'E'),
    ('A1', 'F'),
    ('A1', 'G'),
    ('A1', 'H'),
    ('A1', 'I'),
    ('A1', 'J'),
    ('B', 'B1'),
    ('B', 'B2'),
    ('C', 'C1'),
    ('C', 'C2'),
    ('D', 'D1'),
    ('D', 'D2'),
    ('D', 'D3'),
    ('E', 'E1'),
    ('E', 'E2'),
    ('E', 'E3'),
    ('F', 'F1'),
    ('G', 'G1'),
    ('G', 'G2'),
    ('H', 'H1'),
    ('I', 'I1'),
    ('J', 'J1'),
    ('J', 'J2'),
]

colors = {
    'orchestrator': '#4d94ff',
    'domain': '#7bc47f',
    'persistence': '#ffa64d',
    'repo': '#ffd966',
}

bounds = [(n['idx'][0], n['idx'][1]) for n in nodes.values()]
xs = [p[0] for p in bounds]
ys = [p[1] for p in bounds]
x_min = min(xs) - 1
x_max = max(xs) + 2
y_min = min(ys) - 2
y_max = max(ys) + 2


def band_wh(kind):
    if kind == 'repo':
        return 1.6, 0.8
    if kind in ('domain', 'persistence'):
        return 1.8, 0.9
    return 2.2, 1.0


fig, ax = plt.subplots(figsize=(22, 16), dpi=100)
ax.set_xlim(x_min, x_max)
ax.set_ylim(y_max, y_min)
ax.axis('off')

for k, v in nodes.items():
    x, y = v['idx']
    color = colors[v['kind']]
    w, h = band_wh(v['kind'])
    box = FancyBboxPatch((x - w / 2, y - h / 2), w, h,
                         boxstyle='round,pad=0.05,rounding_size=0.15',
                         facecolor=color, edgecolor='#333', linewidth=1.2, alpha=0.95)
    ax.add_patch(box)
    size = 8 if v['kind'] == 'repo' else 10 if v['kind'] in ('domain', 'persistence') else 11
    ax.text(x, y, v['label'].replace('\n', ' '), ha='center', va='center',
            fontsize=size, fontweight='bold', color='white',
            path_effects=[pe.withStroke(linewidth=0.6, foreground='#000000', alpha=0.35)])


def anchor(x, y, kind, dx, dy):
    w, h = band_wh(kind)
    if abs(dx) >= abs(dy):
        left = x - w / 2
        right = x + w / 2
        if dx < 0:
            return right, y
        return left, y
    top = y - h / 2
    bottom = y + h / 2
    if dy < 0:
        return x, bottom
    return x, top


for src, dst in edges:
    x1, y1 = nodes[src]['idx']
    x2, y2 = nodes[dst]['idx']
    start = anchor(x1, y1, nodes[src]['kind'], x2 - x1, y2 - y1)
    end = anchor(x2, y2, nodes[dst]['kind'], x1 - x2, y1 - y2)
    ax.annotate('', xy=end, xytext=start,
                arrowprops=dict(arrowstyle='->', color='#555555', lw=1.0,
                                shrinkA=4, shrinkB=4, connectionstyle='arc3,rad=0.02'))

ax.set_title('Mapa de dependencias – Agentes MotorSocial', fontsize=14, fontweight='bold', pad=12)
fig.savefig(out, bbox_inches='tight')
print(f'WROTE {out} SIZE={os.path.getsize(out)}')
