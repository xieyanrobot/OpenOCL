function testOclOCP
  
oclDir = getenv('OPENOCL_PATH');
addpath(fullfile(oclDir,'Test','Classes'));

% ocp empty test
ocp = OclTestOcpEmpty;
s = OclTestSystemEmpty;
s.setup();
opt = OclOptions;
opt.controls_regularization = false;
h = OclOcpHandler(1,s,ocp,opt);
h.setup();
assertEqual(h.pathCostsFun.evaluate([],[],[],[]),0);
assertEqual(h.arrivalCostsFun.evaluate([],[]),0);

[val,lb,ub] = h.pathConstraintsFun.evaluate([],[]);
assertEqual(val,[]);
assertEqual(lb,[]);
assertEqual(ub,[]);
[val,lb,ub] = h.boundaryConditionsFun.evaluate([],[],[]);
assertEqual(val,[]);
assertEqual(lb,[]);
assertEqual(ub,[]);

% ocp valid test
ocp = OclTestOcpValid;
s = OclTestSystemValid();
s.independentVar = 'ttt';
s.dependent = true;
N = 2;
nv = (N+1)*s.nx+N*s.nu;
h = OclOcpHandler(1,s,ocp,opt);
h.setup();
h.setNlpVarsStruct(OclMatrix([nv,1]));

c = h.pathCostsFun.evaluate(ones(s.nx,1),ones(s.nz,1),ones(s.nu,1),ones(s.np,1));
assertEqual(c,26+1e-3*12);

c = h.arrivalCostsFun.evaluate(ones(s.nx,1),ones(s.np,1));
assertEqual(c, -1);

% path constraints in the form of : -inf <= val <= 0 or 0 <= val <= 0
[val,lb,ub] = h.pathConstraintsFun.evaluate(ones(s.nx,1),ones(s.np,1));
% ub all zero
assertEqual(ub,zeros(36,1));
% lb either zero for eq or -inf for ineq
assertEqual(lb,[-inf,-inf,0,0,-inf,-inf,-inf*ones(1,5),0,-inf*ones(1,12),-inf*ones(1,12)].');
% val = low - high
assertEqual(val,[0,0,0,0,0,-1,2,2,2,2,2,0,-3*ones(1,12),zeros(1,12)].');

% bc
[val,lb,ub] = h.boundaryConditionsFun.evaluate(2*ones(s.nx,1),3*ones(s.nx,1),ones(s.np,1));
assertEqual(ub,zeros(3,1));
assertEqual(lb,[0,-inf,-inf].');
assertEqual(val,[-1,1,-4].');

c = h.discreteCostsFun.evaluate(ones(nv,1));
assertEqual(c, nv);

rmpath(fullfile(oclDir,'Test','Classes'));
  