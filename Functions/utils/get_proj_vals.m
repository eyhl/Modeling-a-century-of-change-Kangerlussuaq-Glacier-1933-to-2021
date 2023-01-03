function S = get_proj_vals(proj)

r = proj;
S = struct;

s_i = strfind(r,'[')';
c_i = strfind(r,',')';
e_i = strfind(r,']')';
map = [0;sort([s_i;c_i;e_i])];

Lev = [];
for j = 2:size(map,1)
    val = proj((map(j-1,1)+1):(map(j,1)-1));
    tf = isstrprop(val, 'cntrl');
    val = strip(val(~tf),'"');
    r = proj(map(j):end);
    
    switch r(1)
        case '['     
            n = 1;
            nc = 1;
            if ~isempty(Lev)
                g = getfield(S,Lev{:});
                if isfield(g,val)
                    n = size(g.(val).Object,1)+1;
                end
            end
            Lev = [Lev,{val}];
            LevObj = [Lev,'Object'];
            S = setfield(S,{1},LevObj{:},{n,1},{[]});
        case ','
            S = setfield(S,{1},LevObj{:},{n,nc},{val});
            nc = nc+1;
        case ']'
            S = setfield(S,{1},LevObj{:},{n,nc},{val});
            nc = nc+1;
            Lev = Lev(1:end-1);
    end
end
