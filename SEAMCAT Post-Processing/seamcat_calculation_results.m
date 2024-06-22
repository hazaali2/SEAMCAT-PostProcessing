function seamcat_calculation_results(xml_file)
    % Parse the XML file
    data = parse_seamcat_output(xml_file);

    % Perform calculations for each trial for each link
    all_results = [];
    links = fieldnames(data);
    dRSS_values = data.dRSS; % Use the single dRSS value for all links
    for k = 1:length(links)
        link = links{k};
        if strcmp(link, 'dRSS') % Skip the dRSS field
            continue;
        end
        i_block_values = data.(link).iRSS_Blocking;
        i_unwanted_values = data.(link).iRSS_Unwanted;
        noise_floor_values = data.(link).Noise_floor;

        num_trials = length(dRSS_values);
        assert(length(i_block_values) == num_trials);
        assert(length(i_unwanted_values) == num_trials);
        assert(length(noise_floor_values) == num_trials);

        for i = 1:num_trials
            ratios = calculate_ratios(dRSS_values(i), i_block_values(i), i_unwanted_values(i), noise_floor_values(i));
            ratios.Trial = i;
            ratios.Link = link;
            all_results = [all_results; ratios]; %#ok<AGROW>
        end
    end

    % Convert results to a table and display
    results_table = struct2table(all_results);
    disp(results_table);
end

function data = parse_seamcat_output(xml_file)
    % Parse XML file
    xml_data = xml2struct(xml_file);

    % Initialize data structure
    data = struct();

    % Regular expression to match the desired format
    link_regex = 'Link \d+';

    % Parse vectors
    seamcat_results = xml_data.workspaceResults.SEAMCATResults;
    items = seamcat_results.item;
    for i = 1:length(items)
        item = items{i};
        item_name = item.Attributes.name;
        match = regexp(item_name, link_regex, 'match');
        if ~isempty(match)
            link = match{1};
            sanitized_link = sanitize_field_name(link);
            if ~isfield(data, sanitized_link)
                data.(sanitized_link) = struct('iRSS_Blocking', [], 'iRSS_Unwanted', [], 'dRSS', [], 'Noise_floor', []);
            end

            single_values = item.SingleValues.Single;
            if iscell(single_values)
                for j = 1:length(single_values)
                    single = single_values{j};
                    if strcmp(single.Attributes.name, 'Noise floor')
                        data.(sanitized_link).Noise_floor = str2double(single.Attributes.value);
                    end
                end
            else
                if strcmp(single_values.Attributes.name, 'Noise floor')
                    data.(sanitized_link).Noise_floor = str2double(single_values.Attributes.value);
                end
            end

            vector_values = item.VectorValues.Vector;
            disp(vector_values.values.value)
            if iscell(vector_values)
                for j = 1:length(vector_values)
                    vector = vector_values{j};
                    vector_name = vector.Attributes.name;
                    values = extract_values(vector);
                    if contains(vector_name, 'iRSS Blocking') && strcmp(vector.Attributes.group, 'iRSS Blocking')
                        data.(sanitized_link).iRSS_Blocking = values;
                    elseif contains(vector_name, 'iRSS Unwanted') && strcmp(vector.Attributes.group, 'iRSS Unwanted')
                        data.(sanitized_link).iRSS_Unwanted = values;
                    elseif strcmp(vector_name, 'dRSS')
                        data.dRSS = values;
                    end
                end
            else
                vector_name = vector_values.Attributes.name;
                values = extract_values(vector_values);
                if contains(vector_name, 'iRSS Blocking') && strcmp(vector_values.Attributes.group, 'iRSS Blocking')
                    data.(sanitized_link).iRSS_Blocking = values;
                elseif contains(vector_name, 'iRSS Unwanted') && strcmp(vector_values.Attributes.group, 'iRSS Unwanted')
                    data.(sanitized_link).iRSS_Unwanted = values;
                elseif strcmp(vector_name, 'dRSS')
                    data.dRSS = values;
                end
            end
        end
    end
end

function values = extract_values(vector)
    if iscell(vector.values.value)
        disp(vector.values);
        values = str2double({vector.values.value.Attributes.value});
    else
        values = str2double(vector.values.value.Attributes.value);
    end
end

function sanitized_name = sanitize_field_name(name)
    % Replace invalid characters with underscores
    sanitized_name = matlab.lang.makeValidName(name);
end

function ratios = calculate_ratios(C_dBm, I_block_dBm, I_unwanted_dBm, N_dBm)
    % C/I ratio
    C_I_block = C_dBm - I_block_dBm;
    C_I_unwanted = C_dBm - I_unwanted_dBm;
    C_I_total = C_dBm - 10 * log10(10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10));

    % C/(N+I) ratio
    C_NI_block = C_dBm - 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10));
    C_NI_unwanted = C_dBm - 10 * log10(10^(N_dBm/10) + 10^(I_unwanted_dBm/10));
    C_NI_total = C_dBm - 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10));

    % (N+I)/N ratio
    NI_N_block = 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10)) - N_dBm;
    NI_N_unwanted = 10 * log10(10^(N_dBm/10) + 10^(I_unwanted_dBm/10)) - N_dBm;
    NI_N_total = 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10)) - N_dBm;

    % I/N ratio
    I_N_block = I_block_dBm - N_dBm;
    I_N_unwanted = I_unwanted_dBm - N_dBm;
    I_N_total = 10 * log10(10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10)) - N_dBm;

    % Store ratios in a struct
    ratios = struct('C_I_block', C_I_block, 'C_I_unwanted', C_I_unwanted, 'C_I_total', C_I_total, ...
                    'C_NI_block', C_NI_block, 'C_NI_unwanted', C_NI_unwanted, 'C_NI_total', C_NI_total, ...
                    'NI_N_block', NI_N_block, 'NI_N_unwanted', NI_N_unwanted, 'NI_N_total', NI_N_total, ...
                    'I_N_block', I_N_block, 'I_N_unwanted', I_N_unwanted, 'I_N_total', I_N_total);
end
