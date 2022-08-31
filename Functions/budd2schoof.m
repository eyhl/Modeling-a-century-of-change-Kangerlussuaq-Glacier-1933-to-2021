md=loadmodel(org,['Inversion_drag']);

% Budd's Friction coefficient from inversion
CB = md.friction.coefficient;
% Compute the basal velocity
ub = (md.results.StressbalanceSolution.Vx.^2+md.results.StressbalanceSolution.Vy.^2).^(0.5)./md.constants.yts;
ub(md.mask.ice_levelset>0) = nan; % remove no ice region
% exponents in Budd's law
r = 1;
s = 1;
CS_min = 0.01;
CS_max = 1e4;

% To compute the effective pressure
p_ice   = md.constants.g*md.materials.rho_ice*md.geometry.thickness;
p_water = md.materials.rho_water*md.constants.g*(0-md.geometry.base);
% water pressure can not be positive
p_water(p_water<0) = 0;
% effective pressure
Neff = p_ice - p_water;
Neff(Neff<md.friction.effective_pressure_limit) = md.friction.effective_pressure_limit;

% basal shear stress from Budd's law
taub = CB.^2.*Neff.^r.*ub.^s;

% Schoof's law
n = 3.0;  % from Glen's flow law
m = 1.0/n;
Cmax = 0.8; % Iken's bound, scalar in this case for simplicity

% Compute the friction coefficient of Schoof's law
CS = (1./(ub./(taub.^n)-ub./((Cmax.*Neff)).^n) ).^(1/n);

% For the area violate Iken's bound, extrapolate or interpolate from
% surrongdings.
flags = (taub>=Cmax.*Neff);
pos1  = find(flags);
pos2  = find(~flags);
%= griddata(md.mesh.x(pos2),md.mesh.y(pos2),md.friction.coefficient(pos2),md.mesh.x(pos1),md.mesh.y(pos1));
CS = CS.^0.5;
CS(pos1) = CS_max;

% No ice
pos = find(isnan(CS));
CS(pos)  = CS_max;

% set to Schoof's law
md.friction = frictionschoof();
md.friction.C = CS;  % Schoof's law has been changed with C^2 as the coefficient
md.friction.Cmax = Cmax*ones(md.mesh.numberofvertices,1);
md.friction.m = m*ones(md.mesh.numberofelements,1);
% schoof's law has coupling 2 by default in stressbalanceAnalysis.cpp

%Go solve
md.inversion.iscontrol = 0;
md=solve(md,'sb');