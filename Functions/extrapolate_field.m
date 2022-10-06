function [field] = extrapolate_field(md, field, domain)
    % domain = domain of interst, i.e. the area that we want to extrapolate into

    % input misfit or other field
    % input domain.exp to extrapolate into
    if ischar(domain)
        split_str = split(domain_str, ".");
        if strcmp(split_str, "exp")
            domain = ContourToNodes(md.mesh.x, md.mesh.y, domain_str, 2);
        else
            disp("domain has to be either .exp or boolean mask")
        end
    end

    pos = find(domain);           

    F = scatteredInterpolant(md.mesh.x(~domain), md.mesh.y(~domain), field(~domain), 'nearest', 'nearest');                            

    field(pos) = F(md.mesh.x(pos), md.mesh.y(pos));
end


% F = scatteredInterpolant(md.mesh.x(dH2~=0), md.mesh.y(dH2~=0), dH(dH2~=0), 'nearest', 'nearest');                            


% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end));
% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end)>0);
% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end)<0);
% exptool('/data/eigil/work/lia_kq/test.exp');                                                       

% pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/test.exp', 2));           
% dH_test(pos) = F_test(md.mesh.x(pos), md.mesh.y(pos));                                             
% dH_test = dH;                                                                                      
% dH_test(pos) = F_test(md.mesh.x(pos), md.mesh.y(pos));
% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end)<0);
% front_area_small = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_small.exp', 2));
% dH_test(front_area_small) = 0;                                                                                                    
% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end)<0);                               
% front_area_large = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_large.exp', 2));
% dH_test(front_area_large) = 0;                                                                                                    
% front_area_large = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_large.exp', 2));
% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end)<0);                               
% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end)<0);
% exptool('/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_medium.exp');                                                        

% dH_test = dH;                                                                                                                     
% discard = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/dont_update_init_H_here_medium.exp', 2));         
% dH2 = dH;
% dH2(discard) = 0;
% F_test = scatteredInterpolant(md.mesh.x(dH2~=0), md.mesh.y(dH2~=0), dH(dH2~=0), 'nearest', 'nearest');                            
% dH_test(pos) = F_test(md.mesh.x(pos), md.mesh.y(pos));                                                                            
% plotmodel(md, 'data', averaging(md, dH_test, 20), 'mask', md.levelset.spclevelset(1:end-1, end)<0);                       




% md = loadmodel(org, stepName);
% % load obs vel
% disp(['Loading obs velocity from ', vdatafile]);
% Vdata = load(vdatafile);
% vx_obs = Vdata.vx_obs;
% vy_obs = Vdata.vy_obs;
% time = Vdata.time;
% %}}}
% % data processing{{{
% icemask = cell2mat({md.results.TransientSolution(:).MaskIceLevelset});
% Nt = length(time);
% % extrapolate for the element at calving front only
% disp('    Start extrapolating from inland to the ocean side');
% for id = 1:Nt
%    levelset = icemask(:,id); % notice CFLevelset has been modify to compute the gradient
%    vx = vx_obs(:, id);
%    vy = vy_obs(:, id);
%    pos = find(max(levelset(md.mesh.elements),[],2)>0 & min(levelset(md.mesh.elements),[],2)<0);
%    cx = md.mesh.x(md.mesh.elements(pos,:));
%    cy = md.mesh.y(md.mesh.elements(pos,:));
%    crvx = vx(md.mesh.elements(pos,:));
%    crvy = vy(md.mesh.elements(pos,:));
%    Fvx = scatteredInterpolant(cx(:), cy(:), crvx(:), 'nearest','nearest');
%    Fvy = scatteredInterpolant(cx(:), cy(:), crvy(:), 'nearest','nearest');
%    newvx = Fvx(md.mesh.x, md.mesh.y);
%    newvy = Fvy(md.mesh.x, md.mesh.y);
%    posfloat = find(levelset>0);
%    vx_obs(posfloat, id) = newvx(posfloat);
%    vy_obs(posfloat, id) = newvy(posfloat);
% end