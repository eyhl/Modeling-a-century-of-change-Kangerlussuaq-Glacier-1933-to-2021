function [] = movie_thk(md, movieName)
    % get it to fail if I forget name.
    movieName = movieName;
    % TODO: ADD d(thicknesss)/dt plot
    set(0,'defaultfigurecolor',[1, 1, 1])
    % n_times = size(md.results.TransientSolution(:).Vel, 2)
    time = [md.results.TransientSolution.time];
    % output_freq = md.settings.output_frequency;
    % time = time(1:output_freq:end);
    length(time)
    Nt =  length(time);
    nstep = 10;
    nframes = floor(Nt/nstep);
    xl = [0.4302, 0.5121] * 1e6;
    yl = [-2.3107, -2.2116] * 1e6;

    clear mov;
    close all;
    figure()
    mov(1:nframes) = struct('cdata', [],'colormap', []);



    count = 1;
    for i = 1:nstep:Nt
        if isfield(md.results.TransientSolution, 'MaskIceLevelset')
            masked_values = md.results.TransientSolution(i).MaskIceLevelset;
        else
            masked_values = md.mask.ice_levelset;
        end

        plotmodel(md,'data', md.results.TransientSolution(i).Thickness,...
            'levelset', masked_values, 'gridded', 1,...
            'caxis', [1, 3.2e3], 'colorbar', 'on',...
            'log', 10, ...
            'xtick', [], 'ytick', [], ...
            'xlim', xl, 'ylim', yl);%, ...
            % 'tightsubplot#all', 1,...
            % 'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0]); %,...
            % 'subplot', [nRows,nCols,subind(j)]);
        title(sprintf('Velocity in %s', datestr(decyear2date(time(i)), 'yyyy')))
        set(gca,'fontsize', 10);
        % set(colorbar,'visible','off')
        % h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        % title(h, datestr( decyear2date(time(i)), 'yyyy-mm-dd'))
        colormap('turbo')
        img = getframe(1);
        img = img.cdata;
        mov(count) = im2frame(img);
        % set(h, 'visible','off');
        % clear h;
        fprintf(['step ', num2str(count),' done\n']);
        count = count+1;
        clf;
    end
    % create video writer object
    writerObj = VideoWriter(movieName);
    % set the frame rate to one frame per second
    set(writerObj,'FrameRate', 20);
    % open the writer
    open(writerObj);

    for i=1:nframes
        img = frame2im(mov(i));
        [imind,cm] = rgb2ind(img,256,'dither');
        % convert the image to a frame using im2frame
        frame = im2frame(img);
        % write the frame to the video
        writeVideo(writerObj,frame);
    end
    close(writerObj);