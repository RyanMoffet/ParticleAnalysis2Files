function S = LoadImageRawGui(filedir,names)
%function S=LoadStackRaw(filedir)
%
%Imports STXM raw data from input directoy filedir
%filedir needs to contain the STXM header file (.hdr) and the STXM data files (.xim)
%R.C. Moffet, T.R. Henn February 2009
%
%Inputs
%------
%filedir        path to STXM raw data directory
%
%Outputs
%-------
%S              structure array containing imported STXM data
%S.spectr       STXM absorption images
%S.eVenergy     Photon energies used to record images
%S.Xvalue       length of horizontal STXM image axis in µm
%S.Yvalue       length of vertical STXM image axis in µm

cd(filedir)

FileStruct=dir;
numobj=length(names);
cnt=1;
for i = 1:length(names) %% loops through stack folders in raw data folder
    bidx=strfind(names{i},'.hdr');
    if ~isempty(bidx)
        NameBase{cnt}=names{i}(1:end-4);
        cnt=cnt+1;
        clear bidx
    end
end
S.eVenergy=zeros(1,length(NameBase));
for i=1:length(NameBase)
    if i==1
        temp=flipud(load(sprintf('%s_a.xim',NameBase{i})));
        S.spectr=zeros(length(temp(:,1)),length(temp(1,:)),length(NameBase));
        S.spectr(:,:,i)=temp;
        [S.eVenergy(i),S.Xvalue,S.Yvalue]=ReadHdr(sprintf('%s.hdr',NameBase{i}));
        S.particle=NameBase{i};
    else
        S.spectr(:,:,i)=flipud(load(sprintf('%s_a.xim',NameBase{i})));
        [S.eVenergy(i),S.Xvalue,S.Yvalue]=ReadHdr(sprintf('%s.hdr',NameBase{i}));
    end
end
[S.eVenergy,idx]=sort(S.eVenergy);
S.spectr=S.spectr(:,:,idx);
S=AlignStack(S);
if length(S.eVenergy)<5
    Snew=OdStack(S,'map',1);
else
    Snew=OdStack(S,'O',1);
end
%             cd(FinDir)
% load(sprintf('%s%s','F',S.particle));
% Snew=CarbonMaps(Snew);
STACKLab(Snew)% spccnt=1;
try
    S.binmap=Snew.binmap;
catch
    Snew=Snew;
end
save(sprintf('%s%s','F',S.particle))

% for j=1:length(NameBase)
%     S.particle=NameBase{j};
%     for i=3:length(FileStruct)
%         stridx=findstr(FileStruct(i).name,sprintf('%s_a.xim',NameBase{j}));
%         hdridx=findstr(FileStruct(i).name,sprintf('%s.hdr',NameBase{j}));
%
%         if ~isempty(stridx)
%             S.spectr(:,:,j)=flipud(load(FileStruct(i).name));
%             spccnt=spccnt+1;
%         elseif ~isempty(hdridx)
%             [S.eVenergy(j),S.Xvalue,S.Yvalue]=ReadHdr(FileStruct(i).name);
%         end
%     end
% end
% xAxislabel=[0,S.Xvalue];
% yAxislabel=[0,S.Yvalue];
% figure,
% imagesc(xAxislabel,yAxislabel,S.spectr)
% axis image
% colorbar
% title(sprintf('%s, Raw Transmission Image, %g eV',name,S.eVenergy),'Interpreter', 'none','FontSize',14,'FontWeight','normal')
% colormap gray
% xlabel('X-Position (µm)','FontSize',14,'FontWeight','normal')
% ylabel('Y-Position (µm)','FontSize',14,'FontWeight','normal')
% if figsav==1
%     filename=sprintf('%s\%s',varargin{1},name);
%     saveas(gcf,filename,'png');
% end
