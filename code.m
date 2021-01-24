clear  % �������
clc    % ����

%% 1����ȡ����
info1 = ncinfo('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc'); % �鿴����
info2 = ncinfo('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_210001-230012.nc'); % �鿴����
lon = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','lon'); % ��ȡ����
lat = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','lat');  % ��ȡγ��
time1 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','time');  % ��ȡʱ��
time2 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_210001-230012.nc','time');  % ��ȡʱ��
pr1 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','pr',[1,1,890],[inf,inf,inf])*30*24*60*60;  % ��ȡ208001-209912�µ�����
pr2 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_210001-230012.nc','pr',[1,1,1],[inf,inf,12])*30*24*60*60;  % ��ȡ210001-210012�µ�����

%% 2��ת��ʱ���ʽ
t0 = datetime(2006,1,1);                % ���ó�ʼʱ��
% date_yyymmdd = t0 + double(time(:))/24;    % timeΪ��2006��1��1��00ʱ��Сʱ��һά����
t1 = t0 + time1(:);            % timeΪ��2006��1��1��00ʱ������һά����
t1.Format = 'yyyyMMdd';           % ת����������Ҫ��ʱ���ʽ��'yyyyMMMdd','yyyyMMMMdd','MM��dd��'
t_str1 = datestr(t1,'yyyymm');   % datetime��������תΪchar����
t_num1 = str2num(t_str1);          % char����תΪ����double

t0 = datetime(2100,1,1);                % ���ó�ʼʱ��
t2 = t0 + time2(:);            % timeΪ��2100��1��1��00ʱ������һά����
t2.Format = 'yyyyMMdd';           % ת����������Ҫ��ʱ���ʽ��'yyyyMMMdd','yyyyMMMMdd','MM��dd��'
t_str2 = datestr(t2,'yyyymm');   % datetime��������תΪchar����
t_num2 = str2num(t_str2);          % char����תΪ����double

%% 3��ѡ���й���ʡ����γ�ȸ��,ƥ�侭γ��ʱ�併ˮ��
shp = shaperead('C:\Users\ZHAN\Desktop\20210123\gadm36_CHN_shp\gadm36_CHN_1.shp');

[mlon,mlat] = meshgrid(lon,lat);
r = 1;
for i = 1 : size(mlon,1)
    for j = 1 : size(mlat,2)
        xq(r,1) = mlon(i,j);
        yq(r,1) = mlat(i,j);
        r = r + 1;
    end
end

excel_data = []; excel_name = []; rr = 1;
for i = 1 : length(shp)
    i
    name = shp(i).NAME_1
    in = inpolygon(xq, yq, shp(i).X, shp(i).Y); % �ж���Щ�����ʡ����
    pd = sort(in,'descend');  % ���߼�0��1���������У�Ŀ��Ϊ���ж��Ƿ��и����ʡ���ڣ�����У����һ��ֵ�ض���1������0
    if pd(1) %�������һ��ֵΪ�棬��ʼ��������
        lon_lat = [xq(in),yq(in)]; %ʡ���ڵ�����㾭γ��
        % �ҳ�lon_lat��������
        r1 = 1; r2 = 1; mark_lon = []; mark_lat = [];
        for j = 1 : size(lon_lat,1)
            for k = 1 : length(lon)
                if lon_lat(j,1) == lon(k,1)
                    mark_lon(r1,1) = k; %�ҳ�ʡ���ھ�����������
                    r1 = r1 + 1;
                end
            end
        end
        for jj = 1 : size(lon_lat,1)
            for kk = 1 : length(lat)
                if lon_lat(jj,2) == lat(kk,1)
                    mark_lat(r2,1) = kk; %�ҳ�ʡ����γ����������
                    r2 = r2 + 1;
                end
            end
        end
      
        % ��ȡ��ˮֵ
        name_add = [];
        for ii = 1 : length(mark_lon)
            data1(ii,:) = [pr1(mark_lon(ii,1),mark_lat(ii,1),1:239)]; %ǰһ�׶�ʱ��Ľ�ˮ����
            data2(ii,:) = [pr2(mark_lon(ii,1),mark_lat(ii,1),1:12)];  %��һ�׶�ʱ��Ľ�ˮ����
            name_add{ii} = name;
        end
        % ���Ͻ�ˮ���ݺ�ʡ��
        temp = [data1,data2]';  temp_name = name_add;
        excel_data = [excel_data,mean(temp,2)];
%         excel_name = [excel_name,temp_name];
        excel_name{rr} = shp(i).NAME_1; % ʡ����
        rr = rr + 1;
        clear lon_lat data1 data2
    end
end
excel_data_time = [[t_num1(890:end);t_num2(1:12)],excel_data]; %�����ʱ���2080-2100����



















% %% 4��ƥ�侭γ��ʱ�併ˮ��
% [mlon,mlat] = meshgrid(lon,lat);
% mlon = mlon';
% mlat = mlat';
% r = 1;
% data = zeros(size(mlon,1)*size(mlon,2)*(length(time)-889),3); %
% for i = 1 : size(mlon,1)
%     for j = 1 : size(mlat,2)
%         for k = 890 : length(time)
%             data(r,1) = mlon(i,j);
%             data(r,2) = mlat(i,j);
%             data(r,3) = t_num(k);
%             data(r,4) = pr(i,j,k);
%             r = r + 1;
%         end
%     end
% end
%
% load coast.mat
% % r = 1;
% % for i = 1 :1: 64
% %     for j = 1 : 128
% %         aaa(r,1) = mlon(i,j);
% %         aaa(r,2) = mlat(i,j);
% %         r = r + 1;
% %     end
% % end
% %
% plot(long,lat)
% hold on
% scatter(shp(i).X,shp(i).Y,'.')
% scatter(xq(in),yq(in),'*')