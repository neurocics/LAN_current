function lan_master_gui(LAN_var)

LAN = LAN_var;

mainfig = figure('name', 'Welcome to LAN MASTER GUI');
parent_panel = uipanel('units','norm','position',[.26 .01 .73 .98]);
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .94 .25 .06],...
    'string', 'visualization', 'callback', {@cb_btn, mainfig}, 'tag', 'ppro');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .88 .25 .06],...
    'string', 'continuous spectra', 'callback', {@cb_btn, mainfig}, 'tag', 'tfsp');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .82 .25 .06],...
    'string', 'ripples detection', 'callback', {@cb_btn, mainfig}, 'tag', 'drip');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .76 .25 .06],...
    'string', 'load events', 'callback', {@cb_btn, mainfig}, 'tag', 'ldev');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .70 .25 .06],...
    'string', 'spike sorting', 'callback', {@cb_btn, mainfig}, 'tag', 'spks');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .64 .25 .06],...
    'string', 'segmentation', 'callback', {@cb_btn, mainfig}, 'tag', 'segm');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .58 .25 .06],...
    'string', 'power spectrum', 'callback', {@cb_btn, mainfig}, 'tag', 'spec');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .52 .25 .06],...
    'string', 'filters', 'callback', {@cb_btn, mainfig}, 'tag', 'filt');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .46 .25 .06],...
    'string', 'spike-LFP coherence', 'callback', {@cb_btn, mainfig}, 'tag', 'xfre');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .40 .25 .06],...
    'string', 'coherence', 'callback', {@cb_btn, mainfig}, 'tag', 'cohe');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .34 .25 .06],...
    'string', 'select theta', 'callback', {@cb_btn, mainfig}, 'tag', 'sthe');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .28 .25 .06],...
    'string', 'save progress', 'callback', {@cb_btn, mainfig}, 'tag', 'save');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 .22 .25 .06],...
    'string', 'help', 'callback', {@cb_btn, mainfig}, 'tag', 'help');
uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [0 0 .25 .06],...
    'string', 'clear', 'callback', {@cb_btn, mainfig}, 'tag', 'clear');

    function cb_btn(hObj, event, mainfig)
        figure(mainfig)
        delete(subplot(1, 4, [2 3 4]));
        
        tag = get(hObj, 'tag');
        switch tag
            case 'ppro'
                prepro_proto(LAN);
            case 'tfsp'
                delete(get(parent_panel,'children'));
                lan_master_gui_tfsp(LAN, mainfig, parent_panel);
            case 'drip'
                delete(get(parent_panel,'children'));
                lan_master_gui_drip(LAN, mainfig, parent_panel);
            case 'ldev'
                delete(get(parent_panel,'children'));
                lan_master_gui_ldev(LAN, mainfig, parent_panel);
            case 'spks'
                delete(get(parent_panel,'children'));
                lan_master_gui_spks(LAN, mainfig, parent_panel);
            case 'segm'
                delete(get(parent_panel,'children'));
                lan_master_gui_segm(LAN, mainfig, parent_panel);
                msgbox(['Segmentation will irreversibly change your LAN variable at the workspace.'...
                    ' Remember to save your progress.'], 'Attention', 'help');
            case 'spec'
                delete(get(parent_panel,'children'));
                lan_master_gui_spec(LAN, mainfig, parent_panel);
                if LAN.trials == 1
                    msgbox(['It is recommended to segment the signal'...
                        'before calculating power spectra'], 'Attention', 'help');
                end
            case 'filt'
                delete(get(parent_panel,'children'));
                lan_master_gui_filt(LAN, mainfig, parent_panel);
            case 'xfre'
                delete(get(parent_panel,'children'));
                lan_master_gui_sfco(LAN, mainfig, parent_panel);
            case 'cohe'
                delete(get(parent_panel,'children'));
                lan_master_gui_cohe(LAN, mainfig, parent_panel);
                if LAN.trials == 1
                    msgbox(['It is recommended to segment the signal'...
                        'before calculating power spectra'], 'Attention', 'help');
                end
            case 'sthe'
                delete(get(parent_panel,'children'));
                lan_master_gui_sthe(LAN, mainfig, parent_panel);
            case 'save'
                [filename,pathname] = uiputfile([LAN.name '_' LAN.cond '.mat'], 'Save as...');
                if ~isequal(filename,0)
                    save([pathname filename], 'LAN');
                end
            case 'help'
                web('https://bitbucket.org/marcelostockle/lan-toolbox', '-browser');
            case 'clear'
                delete(parent_panel)
                parent_panel = uipanel('units','norm','position',[.26 .01 .73 .98]);
                
        end
    end
end
