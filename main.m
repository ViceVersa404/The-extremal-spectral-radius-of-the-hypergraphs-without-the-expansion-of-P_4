clc 
clear

%计算图F_10的谱半径
solve_hypergraph_spectrum(10, 'F');
%计算图I_11的谱半径
solve_hypergraph_spectrum(11, 'I');
%计算图G_{11,2}的谱半径
solve_hypergraph_spectrum(11, 'G');
%计算图G_{13,3}的谱半径
solve_hypergraph_spectrum(13, 'G');
%计算图G_{15,4}的谱半径
solve_hypergraph_spectrum(15, 'G');
%计算图H_{15,4}'的谱半径
solve_hypergraph_spectrum(15, 'H1');
%计算图H_{15,3}^{'''}的谱半径
solve_hypergraph_spectrum(15, 'H3');
%计算图H_{12,2}^*的谱半径
solve_hypergraph_spectrum(12, 'Hs');
%计算图H_{12,3}^{**}的谱半径
solve_hypergraph_spectrum(12, 'Hss');
%计算图H_{12,2}^{***}的谱半径,注意:H_{12,2}^{***}的特征方程组较为复杂，求解过程耗时极久
%solve_hypergraph_spectrum(12, 'Hsss');




function spectrum_radius = solve_hypergraph_spectrum(n, graph_type)
% 求解超图谱半径
% 输入：
%   n: 图的顶点数
%   graph_type: 'F' 或 'G' 或 'H1' 或 'H3' 或 'I' 或 'Hs' 或 'Hss' 或 'Hsss'，指定图类型
%               'G' 表示 G_{n,k}
%               'H1' 表示 H_{n,k}'
%               'H3' 表示 H_{n,k}^{'''}
%               'F' 表示 F_n（目前仅支持n=10）
%               'I' 表示 I_n（目前仅支持n=11）
%               'Hs' 表示 H_{n,k}^*
%               'Hss' 表示 H_{n,k}^{**}
%               'Hsss' 表示 H_{n,k}^{***}
% 输出：
%   spectrum_radius: 谱半径（最大实数解）

    % 验证输入参数
    if nargin < 2
        error('需要两个输入参数：n 和 graph_type');
    end
    
    if ~isnumeric(n) || n <= 0 || mod(n, 1) ~= 0
        error('n必须是正整数');
    end
    
    valid_types = {'F', 'G', 'H1', 'H3', 'I', 'Hs', 'Hss', 'Hsss'};
    if ~ischar(graph_type) || ~any(strcmpi(graph_type, valid_types))
        error('graph_type必须是''F''、''G''、''H1''、''H3''、''I''、''Hs''、''Hss''或''Hsss''');
    end
    
    % 对于F类型，目前只支持n=10
    if strcmpi(graph_type, 'F') && n ~= 10
        error('目前F图类型仅支持n=10');
    end
    
    % 对于I类型，目前只支持n=11
    if strcmpi(graph_type, 'I') && n ~= 11
        error('目前I图类型仅支持n=11');
    end
    
    % 对于Hs、Hss、Hsss类型，n必须是偶数
    if any(strcmpi(graph_type, {'Hs', 'Hss', 'Hsss'}))
        if mod(n, 2) ~= 0
            error('当图类型为Hs、Hss或Hsss时，n必须是偶数');
        end
    end
    
    % 对于G、H1、H3类型，n必须是奇数
    if any(strcmpi(graph_type, {'G', 'H1', 'H3'}))
        if mod(n, 2) == 0
            error('当图类型为G、H1或H3时，n必须是奇数');
        end
    end
    
    % 计算k值（如果适用）
    if strcmpi(graph_type, 'G') || strcmpi(graph_type, 'H1')
        k = (n - 1) / 2 - 3;
    elseif strcmpi(graph_type, 'H3')
        k = (n - 1) / 2 - 4;
    elseif strcmpi(graph_type, 'Hs') || strcmpi(graph_type, 'Hsss')
        k = n / 2 - 4;
    elseif strcmpi(graph_type, 'Hss')
        k = n / 2 - 3;
    else
        k = NaN;
    end
    
    % 显示开始求解提示
    if strcmpi(graph_type, 'F')
        fprintf('正在求解 F_%d 的特征方程组...\n', n);
    elseif strcmpi(graph_type, 'G')
        fprintf('正在求解 G_{%d,%d} 的特征方程组...\n', n, k);
    elseif strcmpi(graph_type, 'H1')
        fprintf("正在求解 H_{%d,%d}' 的特征方程组...\n", n, k);
    elseif strcmpi(graph_type, 'H3')
        fprintf("正在求解 H_{%d,%d}^{'''} 的特征方程组...\n", n, k);
    elseif strcmpi(graph_type, 'I')
        fprintf('正在求解 I_%d 的特征方程组...\n', n);
    elseif strcmpi(graph_type, 'Hs')
        fprintf('正在求解 H_{%d,%d}^* 的特征方程组...\n', n, k);
    elseif strcmpi(graph_type, 'Hss')
        fprintf('正在求解 H_{%d,%d}^{**} 的特征方程组...\n', n, k);
    elseif strcmpi(graph_type, 'Hsss')
        fprintf('正在求解 H_{%d,%d}^{***} 的特征方程组...\n', n, k);
    end
    
    % 对于F和I图，直接使用原方程组求解
    if strcmpi(graph_type, 'F') || strcmpi(graph_type, 'I')
        radius = solve_original_system(n, graph_type, k);
        spectrum_radius = radius;
        return;
    end
    
    % 对于其他图类型，先尝试原方程组求解
    try
        radius = solve_original_system(n, graph_type, k);
        spectrum_radius = radius;
        return;
    catch
        % 如果原方程组失败，尝试简化方程组
        radius = solve_simplified_system(n, graph_type, k);
        spectrum_radius = radius;
    end
end

function radius = solve_original_system(n, graph_type, k)
% 求解原方程组
    % 定义符号变量
    syms p x0 x1 x2 x3 x4 x5 x6;
    
    % 根据图类型选择方程组
    if strcmpi(graph_type, 'F')
        % F_n 图的方程组
        eqn = [p*x0^2 == 3*x1*x2, ...
               p*x1^2 == x0*x2 + 2*x1*x2, ...
               p*x2^2 == x0*x1 + x1^2 + 2*x2*x3, ...
               p*x3^2 == x2^2, ...
               x0 > 0, x1 > 0, x2 > 0, x3 > 0];
        
        vars = [p, x0, x1, x2, x3];
        
    elseif strcmpi(graph_type, 'G')
        % G_{n,k} 图的方程组
        eqn = [p*x0^2 == k*x1^2 + 3*x2*x3, ...
               p*x1^2 == x0*x1, ...
               p*x2^2 == x0*x3 + 2*x2*x3, ...
               p*x3^2 == x0*x2 + x2^2 + x3^2, ...
               x0 > 0, x1 > 0, x2 > 0, x3 > 0];
        
        vars = [p, x0, x1, x2, x3];
        
    elseif strcmpi(graph_type, 'H1')
        % H_{n,k}' 图的方程组
        eqn = [p*x0^2 == k*x1^2 + 3*x2^2, ...
               p*x1^2 == x0*x1, ...
               p*x2^2 == x0*x2 + x2^2, ...
               x0 > 0, x1 > 0, x2 > 0];
        
        vars = [p, x0, x1, x2];
        
    elseif strcmpi(graph_type, 'H3')
        % H_{n,k}^{'''} 图的方程组
        eqn = [p*x0^2 == k*x1^2 + 2*x2^2, ...
               p*x1^2 == x0*x1, ...
               p*x2^2 == x0*x2 + 2*x2*x3, ...
               p*x3^2 == x2^2, ...
               x0 > 0, x1 > 0, x2 > 0, x3 > 0];
        
        vars = [p, x0, x1, x2, x3];
        
    elseif strcmpi(graph_type, 'I')
        % I_n 图的方程组（目前仅支持n=11）
        eqn = [p*x0^2 == x0*x1 + 4*x2^2, ...
               p*x1^2 == x0^2, ...
               p*x2^2 == 2*x0*x2, ...
               x0 > 0, x1 > 0, x2 > 0];
        
        vars = [p, x0, x1, x2];
        
    elseif strcmpi(graph_type, 'Hs')
        % H_{n,k}^* 图的方程组
        eqn = [p*x0^2 == k*x1^2 + 2*x2^2, ...
               p*x1^2 == x0*x1, ...
               p*x2^2 == x0*x2 + x2*x3 + x2*x4, ...
               p*x3^2 == x2^2, ...
               p*x4^2 == 2*x2^2, ...
               x0 > 0, x1 > 0, x2 > 0, x3 > 0, x4 > 0];
        
        vars = [p, x0, x1, x2, x3, x4];
        
    elseif strcmpi(graph_type, 'Hss')
        % H_{n,k}^{**} 图的方程组
        eqn = [p*x0^2 == k*x1^2 + 2*x2^2, ...
               p*x1^2 == x0*x1, ...
               p*x2^2 == x0*x2 + x2*x3, ...
               p*x3^2 == 2*x2^2, ...
               x0 > 0, x1 > 0, x2 > 0, x3 > 0];
        
        vars = [p, x0, x1, x2, x3];
        
    elseif strcmpi(graph_type, 'Hsss')
        % H_{n,k}^{***} 图的方程组
        eqn = [p*x0^2 == k*x1^2 + 2*x2*x3 + x5*x6, ...
               p*x1^2 == x0*x1, ...
               p*x2^2 == x0*x3 + x2*x5, ...
               p*x3^2 == x0*x2 + x3*x4, ...
               p*x4^2 == x3^2, ...
               p*x5^2 == x0*x6 + x2^2, ...
               p*x6^2 == x0*x5, ...
               x0 > 0, x1 > 0, x2 > 0, x3 > 0, x4 > 0, x5 > 0, x6 > 0];
        
        vars = [p, x0, x1, x2, x3, x4, x5, x6];
    end
    
    % 设置求解参数
    tol = 1e-10;
    precision = 16;
    
    % 求解方程组
    solutions = solve(eqn, vars, 'Real', false);
    
    % 提取p的解
    solp_vpa = vpa(solutions.p, precision);
    
    if isempty(solp_vpa)
        error('方程组无解');
    end
    
    % 筛选实数解
    real_parts = [];
    for i = 1:length(solp_vpa)
        current_sol = solp_vpa(i);
        if abs(imag(current_sol)) < tol
            real_part = real(current_sol);
            if real_part > 0
                real_parts = [real_parts; real_part];
            end
        end
    end
    
    if isempty(real_parts)
        error('未找到正实数解');
    end
    
    % 找到最大的正实数解
    radius = max(real_parts);
    
    % 输出结果
    if strcmpi(graph_type, 'F')
        fprintf('F_%d 的谱半径: %.8f\n\n', n, radius);
    elseif strcmpi(graph_type, 'G')
        fprintf('G_{%d,%d} 的谱半径: %.8f\n\n', n, k, radius);
    elseif strcmpi(graph_type, 'H1')
        fprintf("H_{%d,%d}' 的谱半径: %.8f\n\n", n, k, radius);
    elseif strcmpi(graph_type, 'H3')
        fprintf("H_{%d,%d}^{'''}的谱半径: %.8f\n\n", n, k, radius);
    elseif strcmpi(graph_type, 'I')
        fprintf('I_%d 的谱半径: %.8f\n\n', n, radius);
    elseif strcmpi(graph_type, 'Hs')
        fprintf('H_{%d,%d}^* 的谱半径: %.8f\n\n', n, k, radius);
    elseif strcmpi(graph_type, 'Hss')
        fprintf('H_{%d,%d}^{**} 的谱半径: %.8f\n\n', n, k, radius);
    elseif strcmpi(graph_type, 'Hsss')
        fprintf('H_{%d,%d}^{***} 的谱半径: %.8f\n\n', n, k, radius);
    end
end

function radius = solve_simplified_system(n, graph_type, k)
% 求解简化方程组：将xi/x0作为新变量
    % 定义新变量：令 y_i = x_i/x0
    syms p y1 y2 y3 y4 y5 y6;
    
    % 根据图类型构建简化方程组
    if strcmpi(graph_type, 'G')
        % G_{n,k} 图的简化方程组
        eqn = [p == k*y1^2 + 3*y2*y3, ...
               p*y1^2 == y1, ...
               p*y2^2 == y3 + 2*y2*y3, ...
               p*y3^2 == y2 + y2^2 + y3^2, ...
               y1 > 0, y2 > 0, y3 > 0];
        
        vars = [p, y1, y2, y3];
        
    elseif strcmpi(graph_type, 'H1')
        % H_{n,k}' 图的简化方程组
        eqn = [p == k*y1^2 + 3*y2^2, ...
               p*y1^2 == y1, ...
               p*y2^2 == y2 + y2^2, ...
               y1 > 0, y2 > 0];
        
        vars = [p, y1, y2];
        
    elseif strcmpi(graph_type, 'H3')
        % H_{n,k}^{'''} 图的简化方程组
        eqn = [p == k*y1^2 + 2*y2^2, ...
               p*y1^2 == y1, ...
               p*y2^2 == y2 + 2*y2*y3, ...
               p*y3^2 == y2^2, ...
               y1 > 0, y2 > 0, y3 > 0];
        
        vars = [p, y1, y2, y3];
        
    elseif strcmpi(graph_type, 'Hs')
        % H_{n,k}^* 图的简化方程组
        eqn = [p == k*y1^2 + 2*y2^2, ...
               p*y1^2 == y1, ...
               p*y2^2 == y2 + y2*y3 + y2*y4, ...
               p*y3^2 == y2^2, ...
               p*y4^2 == 2*y2^2, ...
               y1 > 0, y2 > 0, y3 > 0, y4 > 0];
        
        vars = [p, y1, y2, y3, y4];
        
    elseif strcmpi(graph_type, 'Hss')
        % H_{n,k}^{**} 图的简化方程组
        eqn = [p == k*y1^2 + 2*y2^2, ...
               p*y1^2 == y1, ...
               p*y2^2 == y2 + y2*y3, ...
               p*y3^2 == 2*y2^2, ...
               y1 > 0, y2 > 0, y3 > 0];
        
        vars = [p, y1, y2, y3];
        
    elseif strcmpi(graph_type, 'Hsss')
        % H_{n,k}^{***} 图的简化方程组 - 直接使用消元法
        % 从 p*y1^2 = y1 可得 p*y1 = 1，即 y1 = 1/p
        % 定义新变量：令 y_i = x_i/x0
        syms p y2 y3 y4 y5 y6;
        
        % 使用 y1 = 1/p 代入其他方程
        % 方程1: p = k*(1/p^2) + 2*y2*y3 + y5*y6
        % 即: p = k/p^2 + 2*y2*y3 + y5*y6
        % 可写为: p^3 = k + 2*y2*y3*p^2 + y5*y6*p^2
        
        % 建立消元后的方程组
        eqn = [p^3 == k + 2*y2*y3*p^2 + y5*y6*p^2, ...      % 来自方程1
               p*y2^2 == y3 + y2*y5, ...                   % 方程2不变
               p*y3^2 == y2 + y3*y4, ...                   % 方程3不变
               p*y4^2 == y3^2, ...                         % 方程4不变
               p*y5^2 == y6 + y2^2, ...                    % 方程5不变
               p*y6^2 == y5, ...                           % 方程6不变
               p > 0, y2 > 0, y3 > 0, y4 > 0, y5 > 0, y6 > 0];
        
        vars = [p, y2, y3, y4, y5, y6];
        
    end
    
    % 设置求解参数
    tol = 1e-10;
    precision = 16;
    
    % 求解简化方程组
    solutions = solve(eqn, vars, 'Real', false);
    
    % 提取p的解
    solp_vpa = vpa(solutions.p, precision);
    
    if isempty(solp_vpa)
        error('简化方程组无解');
    end
    
    % 筛选实数解
    real_parts = [];
    for i = 1:length(solp_vpa)
        current_sol = solp_vpa(i);
        if abs(imag(current_sol)) < tol
            real_part = real(current_sol);
            if real_part > 0
                real_parts = [real_parts; real_part];
            end
        end
    end
    
    if isempty(real_parts)
        error('简化方程组未找到正实数解');
    end
    
    % 找到最大的正实数解
    radius = max(real_parts);
    
    % 输出结果（来自简化方程组）
    if strcmpi(graph_type, 'G')
        fprintf('G_{%d,%d} 的谱半径: %.8f (通过简化方程组求得)\n\n', n, k, radius);
    elseif strcmpi(graph_type, 'H1')
        fprintf("H_{%d,%d}' 的谱半径: %.8f (通过简化方程组求得)\n\n", n, k, radius);
    elseif strcmpi(graph_type, 'H3')
        fprintf("H_{%d,%d}^{'''} 的谱半径: %.8f (通过简化方程组求得)\n\n", n, k, radius);
    elseif strcmpi(graph_type, 'Hs')
        fprintf('H_{%d,%d}^* 的谱半径: %.8f (通过简化方程组求得)\n\n', n, k, radius);
    elseif strcmpi(graph_type, 'Hss')
        fprintf('H_{%d,%d}^{**} 的谱半径: %.8f (通过简化方程组求得)\n\n', n, k, radius);
    elseif strcmpi(graph_type, 'Hsss')
        fprintf('H_{%d,%d}^{***} 的谱半径: %.8f (通过简化方程组求得)\n\n', n, k, radius);
    end
end


