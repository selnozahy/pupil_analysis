% function pupil_videoextract()
% navigate to folder
dpath = uigetdir();
fname=dir('*EyeCam.bin'); 
cam_file= fullfile(dpath, fname.name);

CAM0.fname = cam_file;
fsize = dir(CAM0.fname);  % File information
CAM0.fsize = fsize.bytes; % Files size in bytes     
% get stack size
% for nx = 250:350
%     for ny =250:350  
nx=350; ny=300;
        CAM0.frmsiz = (nx*ny*8/8); % size of single frame in bytes, resolution
        CAM0.frminf = 3*(32/8); % size of hdr of single frame in bytes
        CAM0.nfrm = CAM0.fsize./(CAM0.frmsiz+CAM0.frminf);
        if round(CAM0.nfrm) == CAM0.nfrm           
            return            
        end
%         if CAM0.nfrm >153000
%             if CAM0.nfrm <155000

%                 if mod(nx,10) == 0
%                     if mod(ny,10) == 0
%                         x=[nx;x]; y=[ny;y];a=[CAM0.nfrm;a];
%         
% end
%                 end
%             end
%         end
%     end
% end
% Read and reshape the file
CAM0.nx = nx; CAM0.ny = ny;
% nx*n=8*((CAM0.fsize/CAM0.nfrm)-CAM0.frminf)/8;
fid = fopen(CAM0.fname);
fseek(fid, 32/8,'bof');

fseek(fid,CAM0.frminf ,'bof'); % skip first header
I=fread(fid,CAM0.nfrm*(CAM0.nx*CAM0.ny),sprintf('%d*uint8=>uint8',(CAM0.nx*CAM0.ny)), CAM0.frminf,'ieee-be');
EyeStack = reshape(I, CAM0.nx,CAM0.ny, CAM0.nfrm);
fclose(fid);

fid = fopen(CAM0.fname);
fseek(fid,0,'bof');
    % read info for all frames
    fseek(fid,1*32/8,'bof');
    CAM0.ms = fread(fid,CAM0.nfrm,'uint32',CAM0.frmsiz+CAM0.frminf-(32/8),'ieee-be'); % tcpu
fclose(fid);
save('CAM0.mat','CAM0');

v = VideoWriter('38E.avi','Grayscale AVI');
open(v);
writeVideo(v, EyeStack);
close(v);
obj = VideoReader('38E.avi');