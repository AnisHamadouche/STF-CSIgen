function scenario_name = getScenarioName(scenestr)
%GETSCENARIONAME  Maps a descriptive scenario string to QuaDRiGa scenario code.
%
%   scenario_name = GETSCENARIONAME(scenestr)
%
%   Input:
%       scenestr - String, e.g. 'UMi+NLoS', 'RMa+LoS', 'Indoor+LoS'
%   Output:
%       scenario_name - String, e.g. '3GPP_38.901_UMi_NLOS'
%
%   Supported scenarios:
%     - UMi+NLoS / UMi+LoS
%     - UMa+NLoS / UMa+LoS
%     - RMa+NLoS / RMa+LoS
%     - Indoor+NLoS / Indoor+LoS
%
%   Defaults to '3GPP_38.901_UMi_LOS' if input not recognized.

    if contains(scenestr, 'UMi')
        if contains(scenestr, 'NLoS')
            scenario_name = '3GPP_38.901_UMi_NLOS';
        else
            scenario_name = '3GPP_38.901_UMi_LOS';
        end
    elseif contains(scenestr, 'UMa')
        if contains(scenestr, 'NLoS')
            scenario_name = '3GPP_38.901_UMa_NLOS';
        else
            scenario_name = '3GPP_38.901_UMa_LOS';
        end
    elseif contains(scenestr, 'RMa')
        if contains(scenestr, 'NLoS')
            scenario_name = '3GPP_38.901_RMa_NLOS';
        else
            scenario_name = '3GPP_38.901_RMa_LOS';
        end
    elseif contains(scenestr, 'Indoor')
        if contains(scenestr, 'NLoS')
            scenario_name = '3GPP_38.901_Indoor_NLOS';
        else
            scenario_name = '3GPP_38.901_Indoor_LOS';
        end
    else
        scenario_name = '3GPP_38.901_UMi_LOS'; % Fallback
    end
end

