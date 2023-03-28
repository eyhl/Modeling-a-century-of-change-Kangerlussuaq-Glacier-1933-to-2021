function solve_stressbalance_frictioncoulomb2(md)
   %compute horizontal velocity, basal friction
   ub=sqrt(md.initialization.vx.^2+md.initialization.vy.^2)./md.constants.yts;
   p_ice   = md.constants.g*md.materials.rho_ice*md.geometry.thickness;
   p_water = max(0.,md.materials.rho_water*md.constants.g*(0-md.geometry.base));
   N = p_ice - p_water;
   pos=find(N<=0); N(pos)=1;

   s=averaging(md,1./md.friction.p,0);
   r=averaging(md,md.friction.q./md.friction.p,0);
   b=(md.friction.coefficient).^2.*(N.^r).*(ub.^s);
   alpha2=md.friction.coefficient.^2.*N.^r.*ub.^(s-1);

   pos = find(ContourToNodes(md.mesh.x,md.mesh.y,'./Exp/spc_vel.exp',2));
   md.stressbalance.spcvx(pos)=md.initialization.vx(pos);
   md.stressbalance.spcvy(pos)=md.initialization.vy(pos);
   md.stressbalance.spcvz(pos)=md.initialization.vz(pos);

   %new friction coefficient
   md.friction=frictionregcoulomb2();
   u1=(u0./md.constants.yts).^(1./m)./N;
   p=1;
   C=b./((ub./(ub+(u1.*N).^m)).^(1./m).*(N.^p));
   %pos1 = find(md.mask.ice_levelset>0);
   %pos2 = find(md.mask.ice_levelset<=0);
   pos1 = find(isnan(C));
   pos2 = find(~isnan(C));
   C(pos1) = griddata(md.mesh.x(pos2),md.mesh.y(pos2),C(pos2),md.mesh.x(pos1),md.mesh.y(pos1),'nearest');
   %C(pos1)=Kriging(md.mesh.x(pos2),md.mesh.y(pos2),C(pos2),md.mesh.x(pos1),md.mesh.y(pos1),'output','idw','boxlength',150,'searchradius',10000);
   %pos=find(ub==0 | N==0); C(pos)=0;

   md.friction.K=u1.*ones(md.mesh.numberofvertices,1);
   md.friction.m=m.*ones(md.mesh.numberofelements,1);
   %md.friction.p=p;
   md.friction.C=C;
end