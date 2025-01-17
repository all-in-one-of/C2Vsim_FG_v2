%% Extract data
%% relative Paths
gis_data = ['..' filesep 'gis_data' filesep];
%% Paths at UCDAVIS LINUX
c2vsim_path = '/media/giorgk/DATA/giorgk/Documents/C2Vsim_FG_v2/C2VSimFG-BETA_PublicRelease/';
mat_data = '/media/giorgk/DATA/giorgk/Documents/C2Vsim_FG_v2/mat_data/';

%% Read Node coordinates
fid = fopen([c2vsim_path 'Preprocessor' filesep 'C2VSimFG_Nodes.dat'],'r');
temp = textscan(fid, '%f %f %f', 30179, 'HeaderLines',90);
fclose(fid);
XY = [temp{1,2} temp{1,3}];
ND_ID = temp{1,1};
for ii = 1:length(ND_ID)
    C2Vsim_nodes(ii,1).ID = ND_ID(ii);
    C2Vsim_nodes(ii,1).X = XY(ii,1);
    C2Vsim_nodes(ii,1).Y = XY(ii,2);
end
C2Vsim_nodes_meta_data = writeMetaData([],'ID','Node ID');
C2Vsim_nodes_meta_data = writeMetaData(C2Vsim_nodes_meta_data,'X, Y','node coordinates');
%% Read stratigraphy
fid = fopen([c2vsim_path 'Preprocessor' filesep 'C2VSimFG_Stratigraphy.dat'],'r');
strat = textscan(fid, '%f %f %f %f %f %f %f %f %f %f', 30179, 'HeaderLines',105);
fclose(fid);
for ii = 1:length(C2Vsim_nodes)
    C2Vsim_nodes(ii,1).GSE = strat{1,2}(ii);
    for jj = 1:4
        C2Vsim_nodes(ii,1).A(1,jj) = strat{1,1+jj*2}(ii);
        C2Vsim_nodes(ii,1).L(1,jj) = strat{1,2+jj*2}(ii);
    end
end
C2Vsim_nodes_meta_data = writeMetaData(C2Vsim_nodes_meta_data,'GSE','Ground surface elevation');
C2Vsim_nodes_meta_data = writeMetaData(C2Vsim_nodes_meta_data,'A','Thickness of aquiclude in Layer i');
C2Vsim_nodes_meta_data = writeMetaData(C2Vsim_nodes_meta_data,'L','Thickness of aquifer in Layer i');
%}
%% Read river file
fid = fopen([c2vsim_path 'Preprocessor' filesep 'C2VSimFG_StreamsSpec.dat'],'r');
% read NRH, NR, NRTB
temp = textscan(fid, '%f / %s', 3, 'HeaderLines',80);
NRH = temp{1,1}(1); %NUmber of stream reaches
NR = temp{1,1}(2); %Number of stream nodes
NRTB = temp{1,1}(3); %Number of data points in tables per stream node
% read comments
for ii = 1:22; tline = fgetl(fid);end
% read rivers one by one
clear C2Vsim_rivers
for ii = 1:NRH
    ii
    % for each stream read
    % a comment line
    while 1
        tline = fgetl(fid);
        if strcmp('C-------------------------------------------------------------------------------',deblank(tline))
            break;
        end
    end
    for jj = 1:5; tline = fgetl(fid);end
    temp = textscan(fid, '%f %f %f %f', 1);
    name = fgetl(fid);
    C2Vsim_rivers(ii,1).ID = temp{1,4}(1);
    C2Vsim_rivers(ii,1).NAME = deblank(name);
    C2Vsim_rivers(ii,1).IBUR = temp{1,2}(1);
    C2Vsim_rivers(ii,1).IBDR = temp{1,3}(1);
    C2Vsim_rivers(ii,1).IDWN = temp{1,4}(1);
    for jj = 1:5; tline = fgetl(fid);end
    temp = textscan(fid, '%f %f', C2Vsim_rivers(ii,1).IBDR - C2Vsim_rivers(ii,1).IBUR+1);
    C2Vsim_rivers(ii,1).IRV = temp{1,1};
    C2Vsim_rivers(ii,1).IGW = temp{1,2};
end
fclose(fid);
%% add coordinates to the rivers
for ii = 1:length(C2Vsim_rivers)
    C2Vsim_rivers(ii,1).X = XY(C2Vsim_rivers(ii,1).IGW,1);
    C2Vsim_rivers(ii,1).Y = XY(C2Vsim_rivers(ii,1).IGW,2);
end
%% Read Elements
fid = fopen([c2vsim_path 'Preprocessor' filesep 'C2VSimFG_Elements.dat'],'r');
temp = textscan(fid, '%f %f %f %f %f %f', 32537, 'HeaderLines',142);
fclose(fid);
MSH = [temp{1,2} temp{1,3} temp{1,4} temp{1,5}];
EL_ID = temp{1,1};
IRGE = temp{1,6};
%%
for ii = 1:size(MSH,1)
    C2Vsim_elem(ii,1).ID = EL_ID(ii,1);
    if MSH(ii,4) == 0
        C2Vsim_elem(ii,1).X = XY(MSH(ii,1:3),1)';
        C2Vsim_elem(ii,1).Y = XY(MSH(ii,1:3),2)';
        C2Vsim_elem(ii,1).ND_ID = MSH(ii,1:3);
    else
        C2Vsim_elem(ii,1).X = XY(MSH(ii,1:4),1)';
        C2Vsim_elem(ii,1).Y = XY(MSH(ii,1:4),2)';
        C2Vsim_elem(ii,1).ND_ID = MSH(ii,1:4);
    end
    C2Vsim_elem(ii,1).IRGE = IRGE(ii,1);
end
%% Save matlab data 
save([mat_data 'C2Vsim_Nodes'], 'C2Vsim_nodes','C2Vsim_nodes_meta_data');
save([mat_data 'C2Vsim_Elements'], 'C2Vsim_elem');
save([mat_data 'C2Vsim_Rivers'], 'C2Vsim_rivers');
