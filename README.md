## 论文标题: The extremal spectral radius of the hypergraphs without the expansion of $P_4$

本代码用于复现论文中的计算结果。

## 环境要求
- MATLAB R2020a 或更高版本
- 需要工具箱：Statistics and Machine Learning Toolbox

## 说明
- `main.m`：主程序
- `solve_hypergraph_spectrum(n, graph_type)`：自定义函数
- `n`: 顶点数
- `graph_type`: 指定图类型'F' 或 'G' 或 'H1' 或 'H3' 或 'I' 或 'Hs' 或 'Hss' 或 'Hsss'，
               'G' 表示 G_{n,k}
               'H1' 表示 H_{n,k}'
               'H3' 表示 H_{n,k}^{'''}
               'F' 表示 F_n（目前仅支持n=10）
               'I' 表示 I_n（目前仅支持n=11）
               'Hs' 表示 H_{n,k}^*
                'Hss' 表示 H_{n,k}^{**}
               'Hsss' 表示 H_{n,k}^{***}
## 运行方式
直接在MATLAB中运行 `main.m`。

