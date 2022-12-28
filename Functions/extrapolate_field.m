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