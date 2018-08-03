function [datevector,outmat,finalheaders]=ReadSimpleSummary(file)

%% Read STXM .hdr file to extract energies and x and y pixel sizes
%% 081011 RCM

filestream = fopen(file, 'r');    %% Open file
cnt=1;
while feof(filestream) == 0
    if cnt==1
        line=fgets(filestream);
        headers=strsplit(line,',');
    end
    line=fgets(filestream);
    cpos=strfind(line,',');
    datestr=line(1:cpos(1)-1);
    slashpos=strfind(datestr,'/')
    month=str2num(datestr(1:slashpos(1)-1));
    day=str2num(datestr(slashpos(1)+1:slashpos(2)-1));
    spacepos=strfind(datestr,' ');
    year=str2num(datestr(slashpos(2)+1:spacepos(1)-1));
    colonpos=strfind(datestr,':');
    hour=str2num(datestr(spacepos(1)+1:colonpos(1)-1));
    min=str2num(datestr(colonpos(1)+1:colonpos(2)-1));
    sec=str2num(datestr(colonpos(2)+1:spacepos(2)-1));
    ampmstr=datestr(spacepos(2)+1:spacepos(2)+2);
    if strcmp(ampmstr,'PM')
        datevector(cnt)=datenum(year,month,day,hour+12,min,sec);
    else
        datevector(cnt)=datenum(year,month,day,hour,min,sec);
    end
    result=strsplit(line,',');
    colvec=[4,6:length(result)];
    outvec=zeros(size(colvec));
    for i=1:length(colvec)
        outvec(i)=str2num(result{colvec(i)});
    end
    if cnt==1
        outmat=outvec;
    else
        outmat=[outmat;outvec];
    end
    cnt=cnt+1
end
for i=1:length(colvec)
    finalheaders{i}=headers{colvec(i)};
end
fclose(filestream);
