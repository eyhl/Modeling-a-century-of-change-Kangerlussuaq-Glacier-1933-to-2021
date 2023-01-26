function [stack] = load_stack(path)
    shape = shaperead(path);
    stack = struct2table(shape);
end