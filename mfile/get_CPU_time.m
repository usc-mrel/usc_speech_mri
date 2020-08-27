function para = get_CPU_time(para)

para.CPUtime.total_fidelity = sum(para.CPUtime.fidelity);
para.CPUtime.total_sTV = sum(para.CPUtime.sTV);
para.CPUtime.total_tTV = sum(para.CPUtime.tTV);
para.CPUtime.total_update = sum(para.CPUtime.update);
para.CPUtime.interative_recon = para.CPUtime.total_fidelity + para.CPUtime.total_sTV + para.CPUtime.total_tTV + para.CPUtime.total_update;
if isfield(para.CPUtime,'VBM4D')
    para.CPUtime.total_VBM4D = sum(para.CPUtime.VBM4D);
    para.CPUtime.interative_recon = para.CPUtime.interative_recon + para.CPUtime.total_VBM4D;
end
if isfield(para.CPUtime,'load_para_time')
    para.CPUtime.pre_iteration = para.CPUtime.load_para_time;
else
    para.CPUtime.pre_iteration = 0;
end
if isfield(para.CPUtime,'PCA')
    para.CPUtime.pre_iteration = para.CPUtime.pre_iteration + para.CPUtime.PCA;
end
if isfield(para.CPUtime,'prepare_kSpace')
    para.CPUtime.pre_iteration = para.CPUtime.pre_iteration + para.CPUtime.prepare_kSpace;
end
if isfield(para.CPUtime,'estimate_sens_map')
    para.CPUtime.pre_iteration = para.CPUtime.pre_iteration + para.CPUtime.estimate_sens_map;
end
if isfield(para.CPUtime,'initial_est')
    para.CPUtime.pre_iteration = para.CPUtime.pre_iteration + para.CPUtime.initial_est;
end
para.CPUtime.total = para.CPUtime.pre_iteration + para.CPUtime.interative_recon;
