function [] = movie_misfit(md, data_folder, iterations, movieName)
    set(0,'defaultfigurecolor',[1, 1, 1])
    xl = [4.578, 5.152]*1e5;
    yl = [-2.3039, -2.2563]*1e6;

    filePattern = fullfile(data_folder, 'misfit_thickness*'); % Change to whatever pattern you need.
    all_files = dir(filePattern);
    the_files = {all_files(:).name};
    sorted_files = natsort(the_files);
    data_stack = zeros(length(md.geometry.surface), iterations);
    for k = 1 : length(sorted_files)
        baseFileName = sorted_files(k);
        fullFileName = fullfile(all_files(k).folder, baseFileName);
        data = load(fullFileName{1});
        data_stack(:, k) = data.misfit_thickness;
    end

    clear mov;
    close all;
    figure(101)
    mov(1:iterations) = struct('cdata', [],'colormap', []);
    count = 1;
    for i = 1:iterations
        plotmodel(md,'data', data_stack(:, i),...
            'caxis', [-100, 100], 'colorbar', 'off',...
            'xtick', [], 'ytick', []);%, ...
            % 'tightsubplot#all', 1,...
            % 'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0]); %,...
            % 'subplot', [nRows,nCols,subind(j)]);
        title('Misfit updates', 'interpreter','latex')
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        title(h, i)
        colormap('turbo')
        img = getframe(1);
        img = img.cdata;
        mov(i) = im2frame(img);
        set(h, 'visible','off');
        clear h;
        fprintf(['step ', num2str(i),' done\n']);
        clf;
    end
    % create video writer object
    writerObj = VideoWriter(movieName);
    % set the frame rate to one frame per second
    set(writerObj,'FrameRate', 2);
    % open the writer
    open(writerObj);
    mov
    for i=1:iterations
        img = frame2im(mov(i));
        [imind, cm] = rgb2ind(img, 256, 'dither');
        % convert the image to a frame using im2frame
        frame = im2frame(img);
        % write the frame to the video
        writeVideo(writerObj, frame);
    end
    close(writerObj);