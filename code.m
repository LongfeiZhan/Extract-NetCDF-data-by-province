clear  % 清除变量
clc    % 清屏

%% 1、读取数据
info1 = ncinfo('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc'); % 查看变量
info2 = ncinfo('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_210001-230012.nc'); % 查看变量
lon = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','lon'); % 读取经度
lat = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','lat');  % 读取纬度
time1 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','time');  % 读取时间
time2 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_210001-230012.nc','time');  % 读取时间
pr1 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_200601-209912.nc','pr',[1,1,890],[inf,inf,inf])*30*24*60*60;  % 读取208001-209912月的数据
pr2 = ncread('pr_Amon_bcc-csm1-1_rcp45_r1i1p1_210001-230012.nc','pr',[1,1,1],[inf,inf,12])*30*24*60*60;  % 读取210001-210012月的数据

%% 2、转换时间格式
t0 = datetime(2006,1,1);                % 设置初始时间
% date_yyymmdd = t0 + double(time(:))/24;    % time为距2006年1月1日00时的小时数一维数组
t1 = t0 + time1(:);            % time为距2006年1月1日00时的日数一维数组
t1.Format = 'yyyyMMdd';           % 转换成任意想要的时间格式，'yyyyMMMdd','yyyyMMMMdd','MM月dd日'
t_str1 = datestr(t1,'yyyymm');   % datetime数据类型转为char类型
t_num1 = str2num(t_str1);          % char类型转为数组double

t0 = datetime(2100,1,1);                % 设置初始时间
t2 = t0 + time2(:);            % time为距2100年1月1日00时的日数一维数组
t2.Format = 'yyyyMMdd';           % 转换成任意想要的时间格式，'yyyyMMMdd','yyyyMMMMdd','MM月dd日'
t_str2 = datestr(t2,'yyyymm');   % datetime数据类型转为char类型
t_num2 = str2num(t_str2);          % char类型转为数组double

%% 3、选出中国各省区域经纬度格点,匹配经纬度时间降水量
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
    in = inpolygon(xq, yq, shp(i).X, shp(i).Y); % 判断哪些格点在省界内
    pd = sort(in,'descend');  % 将逻辑0、1按降序排列，目的为了判断是否有格点在省界内，如果有，则第一个值必定是1，否则0
    if pd(1) %即如果第一个值为真，则开始后续计算
        lon_lat = [xq(in),yq(in)]; %省界内的网格点经纬度
        % 找出lon_lat所在行数
        r1 = 1; r2 = 1; mark_lon = []; mark_lat = [];
        for j = 1 : size(lon_lat,1)
            for k = 1 : length(lon)
                if lon_lat(j,1) == lon(k,1)
                    mark_lon(r1,1) = k; %找出省界内经度所在行数
                    r1 = r1 + 1;
                end
            end
        end
        for jj = 1 : size(lon_lat,1)
            for kk = 1 : length(lat)
                if lon_lat(jj,2) == lat(kk,1)
                    mark_lat(r2,1) = kk; %找出省界内纬度所在行数
                    r2 = r2 + 1;
                end
            end
        end
      
        % 提取降水值
        name_add = [];
        for ii = 1 : length(mark_lon)
            data1(ii,:) = [pr1(mark_lon(ii,1),mark_lat(ii,1),1:239)]; %前一阶段时间的降水数据
            data2(ii,:) = [pr2(mark_lon(ii,1),mark_lat(ii,1),1:12)];  %后一阶段时间的降水数据
            name_add{ii} = name;
        end
        % 整合降水数据和省份
        temp = [data1,data2]';  temp_name = name_add;
        excel_data = [excel_data,mean(temp,2)];
%         excel_name = [excel_name,temp_name];
        excel_name{rr} = shp(i).NAME_1; % 省份名
        rr = rr + 1;
        clear lon_lat data1 data2
    end
end
excel_data_time = [[t_num1(890:end);t_num2(1:12)],excel_data]; %添加了时间的2080-2100数据
