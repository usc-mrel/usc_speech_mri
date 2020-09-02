function sens_map = get_sens_map(im,options)

smooth = 20;

if size(im,4) == 1 & ~contains(options,'3D')
    sens_map = ones(size(im,1),size(im,2),'single');
    return
end
    
switch options
    case '2D'
        im_for_sens = squeeze(sum(im,3));
        sens_map(:,:,1,:) = ismrm_estimate_csm_walsh_optimized(im_for_sens,smooth);
        
end

sens_map_scale = max(abs(sens_map(:)));
sens_map = sens_map/sens_map_scale;
sens_map_conj = conj(sens_map);

sens_correct_term = 1./sum(sens_map_conj.*sens_map,4);

sens_correct_term = sqrt(sens_correct_term);
sens_map = bsxfun(@times,sens_correct_term,sens_map);

sens_map = single(sens_map);