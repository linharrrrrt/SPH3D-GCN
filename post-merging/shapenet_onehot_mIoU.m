function shapenet_onehot_mIoU(dataDir,resultDir)

[shapenames,folders,numparts,cumtotals] = textread(fullfile(dataDir,'class_info_all.txt'),'%s %s %d %d\n');
for k = 1:numel(folders)
    field = sprintf('f%s',folders{k});
    dict.(field) = [numparts(k) cumtotals(k)];    
    shape_ious.(shapenames{k}) = [];
    dict_names.(field) = shapenames{k};
end
    
fid = fopen('train_test_split/shuffled_test_file_list.json'); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
testfiles = jsondecode(str);
for i = 1:numel(testfiles)
    str = split(testfiles{i},'/');
    gtpath = fullfile(dataDir,sprintf('%s/%s.txt',str{2},str{3}));
    
    data = load(gtpath);
    gt = data(:,end)-1;
    
    respath = fullfile(resultDir,sprintf('%d.txt',i-1));
    res = load(respath);
    pred = res(:,1);
    
    assert(sum(gt==res(:,2))==numel(gt),'ground truth mismatch!');
    
    field = sprintf('f%s',str{2});    
    IoU = evaluateIoU(pred,gt,dict.(field)(1),dict.(field)(2));
    
    fname = dict_names.(field);
    shape_ious.(fname) = [shape_ious.(fname);IoU'];
end

IoU_all = [];
IoU_separate = [];
for k = 1:numel(folders)
    fname = shapenames{k};
    class_IoU = mean(shape_ious.(fname),2);
    IoU_all = [IoU_all;class_IoU];
    fprintf('%s: %.2f%%\n',fname,mean(class_IoU)*100);
    IoU_separate(k) = mean(class_IoU);
end
fprintf('total: %.2f%%\n',mean(IoU_all)*100);
fprintf('mean: %.2f%%\n',mean(IoU_separate)*100);
