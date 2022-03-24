%% help

web('https://bitbucket.org/marcelostockle/lan-toolbox/wiki/edit/Creating%20a%20LAN%20variable', '-browser')

%% make LAN manually
LAN = [];
LAN.srate = 1000; % Sampling rate.
LAN.data{1} = data1; % data1 is a matrix of sampled data in rows.

LAN = lan_check(LAN);
lan_fill_gui(LAN);
%% make LAN from a .csv file
LAN = lan_from_csv();
LAN.srate = 1000; % Sampling rate. Must be entered manually.

LAN = lan_check(LAN);
lan_fill_gui(LAN);
% LAN = lan_add_tll(LAN);
%% make LAN from a .dat file
LAN = lan_from_dat();
LAN.srate = 1000; % Sampling rate. Must be entered manually.

LAN = lan_check(LAN);
lan_fill_gui(LAN);
%% make LAN from a .trc file
LAN = lan_from_trc();
LAN.srate = 512; % Sampling rate. Must be entered manually.

LAN = lan_check(LAN);
lan_fill_gui(LAN);

%% make LAN from a .cnt file
LAN = cnt2lan();

LAN = lan_check(LAN);
lan_fill_gui(LAN);

%% make LAN from a .nsx file
LAN = lan_from_nsx([1 2], 30000);

LAN = lan_check(LAN);
lan_fill_gui(LAN);

%% make LAN from a .ncs file
mergetrials = true;
LAN = lan_from_ncs(mergetrials);

LAN = lan_check(LAN);
lan_fill_gui(LAN);

%% make LAN from a .int file
% IMPORTANT :
% - arg1 : number of channels (required)
% - arg2 : new sampling rate (optional). Default : 25000 Hz
LAN = lan_from_int(16, 1000);
% LAN = lan_from_int(16);

LAN = lan_check(LAN);
lan_fill_gui(LAN);

%% make LAN from a .rhd file
% - arg1 : new sampling rate (optional)
LAN = lan_from_rhd;

LAN = lan_check(LAN);
lan_fill_gui(LAN);

%% make LAN from a .ibw file
LAN = lan_from_ibw();

LAN = lan_check(LAN);
lan_fill_gui(LAN);

%% mix trials
LAN = mix_trials(LANa, LANb);

%% Start GUI
lan_master_gui(LAN)
