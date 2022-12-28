%% THIS CAN BE DELETED - CODE IMPLEMENTED IN extrapolate_smb!!!!

% experiment with kriging
addpath(genpath('Functions/SeReM/'))

%% Example 2
% %% TODO: 
% 1) CREATE REGULAR GRID X Y for area, dense to avoid too much distortion
% 2) Complete kriging example for area with 0 smb
% 2a) plot and find best parameters
% 3) Interpolate kriged smb values back onto md.smb.mass_balance(pos_smb_zero)
% 4) it might be possible to draw various realisations
front_area_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area.exp', 2));
front_area_smb = mean(md.smb.mass_balance(front_area_pos, :), 2);                                                                      

x = md.mesh.x(front_area_pos);
y = md.mesh.y(front_area_pos);

est_corr_dist_x = abs(495483 - 492987); % read off from plot
est_corr_dist_y = abs(-2292770 - (-2293940)); % read off from plot

% extract mean and std from data with meaningful smb. 
% On average values above -1.5 are related to ocean or front-ocean interface in the relevant area:
zero_pos = find(front_area_smb > -1.5);
tmp_values = front_area_smb; 
tmp_values(zero_pos) = NaN;
tmp_mean = nanmean(tmp_values);
tmp_std = nanstd(tmp_values);

% create corr struct for randomfield()
corr_struct.name = 'exp';
corr_struct.c0 = [est_corr_dist_x, est_corr_dist_y];  % anisotropic
corr_struct.sigma = tmp_std ^ 2;

% compute random field, generating more samples is quick (init is slow)
RF = randomfield(corr_struct, mesh, 'nsamples', 1, 'mean', mean_);

% define gridded interpolator based on RF
xq = linspace(min(x), max(x), 1e2);
yq = linspace(min(y), max(y), 1e2);
[Xq, Yq] = ndgrid(xq, yq);
G = griddedInterpolant(Xq, Yq, reshape(RF, 100, 100));

% interpolate onto original data coordinates
vq = G(x(zero_pos), y(zero_pos));

% set random field values back into smb
front_area_smb(zero_pos) = vq;

% zero_pos = find(front_area_smb == 0);
% values_tmp = front_area_smb; % select only non-zero values
% values_tmp(zero_pos) = NaN;
% mean_ = nanmean(values_tmp);
% std_ = nanstd(values_tmp);
% generated_values = mean_ + std_ * randn(2000);
% smoothed_values = imgaussfilt(generated_values,'FilterSize',3);
% front_area_smb



% xq = linspace(min(x), max(x), 1e2);
% yq = linspace(min(y), max(y), 1e2);
% [Xq, Yq] = meshgrid(xq, yq);

% F = scatteredInterpolant(x, y, front_area_smb, 'nearest', 'nearest');
% Vq = F(Xq, Yq);





% zero_pos = find(front_area_smb == 0);
% xcoords = [ Xq(zero_pos) Yq(zero_pos) ];
% n = size(query_coords, 1);

% % available data (15 measurements)
% % dcoords = [ dx dy ]; % for the set of 100 measurements simply comment line 56
% dcoords = [ x y ]; % for the set of 100 measurements simply comment line 56
% % nd = size(dcoords,1);
% % grid of coordinates of the location to be estimated
% % xcoords = [ X(:) Y(:) ];
% % n = size(xcoords,1);

% % parameters random variable
% zmean = 2476;
% zvar = 8721;
% l = 12.5;
% type = 'exp';

% % % plot
% % figure(3)
% % scatter(dcoords(:,1), dcoords(:,2), 50, dz, 'filled');
% % grid on; box on; xlabel('X'); ylabel('Y'); colorbar; caxis([2000 2800]); 

% % % kriging
% % xsk = zeros(nd,1);
% % xok = zeros(nd,1);
% % for i=1:n
% %     % simple kiging
% %     [xsk(i), ~] = SimpleKriging(xcoords(i,:), dcoords, dz, zmean, zvar, l, type);
% %     % ordinary kiging
% %     [xok(i), ~] = OrdinaryKriging(xcoords(i,:), dcoords, dz, zvar, l, type);
% % end
% % xsk = reshape(xsk,size(X));
% % xok = reshape(xok,size(X));

% % Sequential Gaussian Simulation
% krig = 1;
% nsim = 3;
% sgsim = zeros(size(x,1),size(x,2),nsim);
% for i=1:nsim
%     sim = SeqGaussianSimulation(xcoords, dcoords, front_area_smb, zmean, zvar, l, type, krig);
%     sgsim(:,:,i) = reshape(sim, size(X,1), size(X,2));
% end
% % plot results
% figure(2)
% histogram(gsim);
% hold on
% % plot(xsk, 0, '*r')
% % plot(xok, 0, 'sb')
% plot(mean(gsim), 0, 'og')
% grid on; box on; xlabel('Property'); ylabel('Frequency'); 
% legend('Gauss Sims.', 'Simple Krig.', 'Ord. Krig.', 'mean Gauss Sims.');