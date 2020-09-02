function step = line_search(old, update, Data, para)
%--------------------------------------------------------------------------
%   [step] = line_search(old, update, Data, para)
%--------------------------------------------------------------------------
%   Line search called in a conjugate gradient algorithm
%--------------------------------------------------------------------------
%   Inputs:      
%       - old       [sx, sy, nof, ...]
%       - update    [sx, sy, nof, ...]
%       - Data      [structure]
%       - para      [structure]
%               
%       - old       image from previous iteration
%       - update    update term
%       - Data      see 'help STCR_conjugate_gradient.m'
%       - para      see 'help STCR_conjugate_gradient.m'
%--------------------------------------------------------------------------
%   Output:
%       - step      [scalar]
%
%       - step      step size for CG update
%--------------------------------------------------------------------------
%   This function trys to find a suitable step size to perform a CG update.
%   The function starts with a step size adopted from last iteration, and
%   multiply it by 1.3 (magic number). If the step size yeilds a cost that
%   is larger than the previous cost, it shrinks the step size by 0.8
%   (magic number again). If it yeilds a cost that is smaller than the
%   previous cost, it will increase the step size by 1.3 until it no longer
%   yeild a smaller cost. The maximum number of trys is 15.
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

step_start = para.Recon.step_size(end)*1.3; % magic number
%step_start = 2;
%step_start = para.Recon.step_size(1);
tau = 0.8; % magic number again
tau_2 = 1.3;
max_try = 20;
step = step_start;

cost_old = para.Cost.totalCost(end);
flag = 0;

for i=1:max_try
%      fprintf(['Iter = ' num2str(i) '... '])
    
    new = old + step * update;
    fidelity_new = compute_fidelity_for_line_search(new, Data, para);

    cost_new = Cost_STCR(fidelity_new,new,para.Recon.weight_sTV,para.Recon.weight_tTV);

%     fprintf(['Cost new = ' num2str(round(cost_new)) '...\n'])
    if cost_new > cost_old && flag == 0
        step = step * tau;
    elseif cost_new < cost_old 
        step = step * tau_2;
        cost_old = cost_new;
        flag = 1;
    elseif cost_new > cost_old && flag == 1
        step = step / tau_2;
%          fprintf(['Step = ' num2str(step) '...\n'])
%          fprintf(['Cost = ' num2str(round(cost_old)) '...\n'])
        return
    end
end
%  fprintf(['Step = ' num2str(step) '...\n'])
%  fprintf(['Cost = ' num2str(round(cost_new)) '...\n'])
