function c = redgrayblue(m)
    %REDBLUE    Shades of red and blue color map
    %   REDBLUE(M), is an M-by-3 matrix that defines a colormap.
    %   The colors begin with bright blue, range through shades of
    %   blue to white, and then through shades of red to bright red.
    %   REDBLUE, by itself, is the same length as the current figure's
    %   colormap. If no figure exists, MATLAB creates one.
    %
    %   For example, to reset the colormap of the current figure:
    %
    %             colormap(redblue)
    %
    %   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
    %   COLORMAP, RGBPLOT.
    %   Adam Auton, 9th October 2009
    if nargin < 1
        m = size(get(gcf, 'colormap'), 1);
    end
    
    if (mod(m, 2) == 0)
        % From [0 0 1] to [0.8 0.8 0.8], then [1 0 0];
        m1 = m * 0.5;
        
        gray_portion = 0.15; % Adjust this value to change the gray transition
        m_gray = floor(m1 * gray_portion);
        m_red_blue = m1 - m_gray;
        
        r = [linspace(0, 0.83, m_red_blue)'; linspace(0.83, 0.83, m_gray)'; linspace(0.83, 1, m_red_blue)'];
        g = [linspace(0, 0.83, m_red_blue)'; linspace(0.83, 0.83, m_gray)'; linspace(0.83, 0, m_red_blue)'];
        b = [linspace(1, 0.83, m_red_blue)'; linspace(0.83, 0.83, m_gray)'; linspace(0.83, 0, m_red_blue)'];
        
    else
        % From [0 0 1] to [0.8 0.8 0.8], then [1 0 0];
        m1 = floor(m * 0.5);
        
        gray_portion = 0.2; % Adjust this value to change the gray transition
        m_gray = floor((m1 + 1) * gray_portion);
        m_red_blue = m1 + 1 - m_gray;
        
        r = [linspace(0, 0.83, m_red_blue)'; linspace(0.83, 0.83, m_gray)'; linspace(0.83, 1, m_red_blue)'];
        g = [linspace(0, 0.83, m_red_blue)'; linspace(0.83, 0.83, m_gray)'; linspace(0.83, 0, m_red_blue)'];
        b = [linspace(1, 0.83, m_red_blue)'; linspace(0.83, 0.83, m_gray)'; linspace(0.83, 0, m_red_blue)'];
    end
    
    c = [r g b];
    
    
    
    