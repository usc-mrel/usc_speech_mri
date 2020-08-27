ccc

excel_files = dir('../../excel sheets/*xlsx');
excel_files = [excel_files; dir('../../excel_sheets_ks/*xlsx')];
excel_files = [excel_files; dir('../../excel_sheets_yb//*xlsx')];

table_all = table;

for i = 1:length(excel_files)
    file_name = fullfile(excel_files(i).folder, excel_files(i).name);
    table_temp = readtable(file_name);
    table_temp.Properties.VariableNames{3} = 'File1';
    if ~isfield('Var6', table_temp)
        table_temp.Var6 = cell(size(table_temp, 1), 1);
    end
    folder_name = excel_files(i).name(1:end-5);
    if contains(folder_name, 'sample')
        continue
    end
    folder_name(12) = '/';
    for ii = 1:size(table_temp, 1)
        table_temp.File1{ii} = [folder_name, '/2drt/mp4_with_audio/', table_temp.File1{ii}];
        
    end
    if ~iscell(table_temp.File2)
        if isnan(table_temp.File2(1))
            table_temp.File2 = cell(size(table_temp, 1), 1);
        end
    end
    if ~iscell(table_temp.Note)
        if isnan(table_temp.Note(1))
            table_temp.Note = cell(size(table_temp, 1), 1);
        end
    end
    table_all = [table_all; table_temp];
    
end

writetable(table_all, 'table_all.xlsx');