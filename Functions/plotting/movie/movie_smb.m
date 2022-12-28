function [] = movie_smb(md, movieName)
    % TODO: ADD d(thicknesss)/dt plot
    set(0,'defaultfigurecolor',[1, 1, 1])
    % n_times = size(md.results.TransientSolution(:).Vel, 2)
    % time = [md.results.TransientSolution.time];
    years_of_simulation = 1900:2021;
    time = [years_of_simulation(1):1/12:years_of_simulation(end)+11/12];
    output_freq = md.settings.output_frequency;
    % time = time(1:output_freq:end);
    length(time)
    Nt = length(time);
    nstep = 1;
    % nframes = floor(Nt/nstep) - 1;
    nframes = length(1:12:(Nt-12));
    disp(nframes)

    
 
    clear mov;
    close all;
    figure()
    mov(1:nframes) = struct('cdata', [],'colormap', []);
    disp(size(mov))
    count = 1;
    year = 1900;
    for i = 1:12:(Nt-12)
        data = mean(md.smb.mass_balance(1:end-1, i:i+12), 2);
        plotmodel(md,'data', data,...
            'gridded', 1,...
            'caxis', [-5, 5], 'colorbar', 'off',...
            'ylim', yl, 'xlim', xl,...
            'xtick', [], 'ytick', []);%, ...
            % 'tightsubplot#all', 1,...
            % 'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0]); %,...
            % 'subplot', [nRows,nCols,subind(j)]);
        title('SMB, yearly average', 'interpreter','latex')
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.05  0.75  0.01], 'Location', 'southoutside');
        title(h, sprintf('%d', year));
        colormap('turbo')
        img = getframe(1);
        img = img.cdata;
        mov(count) = im2frame(img);
        set(h, 'visible','off');
        clear h;
        fprintf(['step ', num2str(count),' done\n']);
        count = count+1;
        if rem(i, 12) == 1
            year = year + 1;
        end
        clf;
    end
    disp(count)

    % create video writer object
    writerObj = VideoWriter(movieName);
    % set the frame rate to one frame per second
    set(writerObj,'FrameRate', 20);
    % open the writer
    open(writerObj);
    for i=1:nframes
        img = frame2im(mov(i));
        [imind,cm] = rgb2ind(img, 256,'dither');
        % convert the image to a frame using im2frame
        frame = im2frame(img);
        % write the frame to the video
        writeVideo(writerObj,frame);
    end
    close(writerObj);