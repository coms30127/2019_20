using Plots, Statistics, StatsBase

# Parameters
r_0 = 20 # Hz # baseline firing rate
B = 20 # Hz # amplitude of firing rate oscillation around baseline
f = 2 # Hz; frequency of firing rate oscillation
runtime = 1 # seconds; total run time
dt = 0.025e-3 # seconds; time step

# Compute spike train
t = 0. # initialise time
spiketrain = [] # initialise spike train array
while t<=runtime
    rate = r_0 + B*sin(f*2*pi*t) # compute firing rate at this timestep
    if rand()<rate*dt # is there a spike? yes or no
        push!(spiketrain,t) # append current time to spike train array
    end
    global t = t + dt # increment time
end

# Plot spike train
scatter(spiketrain,ones(length(spiketrain)),grid=false,xlabel="Time (s)",ylim=(0, 2),label="")

# Compute auto correlation
delta_corr = 0.05 # seconds; time bin for correlogram
acorr_lim = 1. # seconds; limit for autocorrelogram
acorr_tvec = collect(-acorr_lim-delta_corr/2: delta_corr : acorr_lim+delta_corr/2) # time bins for autocorrelogram
acorr = zeros(length(acorr_tvec)-1)
for i = 1:length(spiketrain)
    target_spike = spiketrain[i]
    for j = 2:length(acorr_tvec)
        shifted_train = spiketrain .- target_spike
        count = sum( (shifted_train.>acorr_tvec[j-1]) .& (shifted_train.<acorr_tvec[j]) )
        acorr[j-1] += count
    end
end

# Plot autocorrelogram
bar(acorr_tvec,acorr,label="",xlabel="Time lag (s)",ylabel="Auto correlation",grid=false)


#####
# CROSS CORRELOGRAM
#####

# make two spike trains, A and B, where B is shifted in time relative to A
AB_lag = 0.2 # seconds; time lag from A to B
t = 0. # initialise time
runtime_ = 1.
spiketrain_A = [] # initialise spike train array
spiketrain_B = [] # initialise spike train array
while t<=runtime_
    rate_A = r_0 + B*sin(f*2*pi*t) # compute firing rate at this timestep
    rate_B = r_0 + B*sin(f*2*pi*(t-AB_lag)) # compute firing rate at this timestep
    if rand()<rate_A*dt # is there a spike? yes or no
        push!(spiketrain_A,t) # append current time to spike train array
    end
    if rand()<rate_B*dt # is there a spike? yes or no
        push!(spiketrain_B,t) # append current time to spike train array
    end
    global t = t + dt # increment time
end

# Plot spike train
scatter(spiketrain_A,ones(length(spiketrain_A)),grid=false,xlabel="Time (s)",ylim=(0, 3),label="A")
    scatter!(spiketrain_B,2*ones(length(spiketrain_B)),label="B",color=:red)

# Compute auto correlation
delta_crosscorr = 0.05 # seconds; time bin for correlogram
crosscorr_lim = 1. # seconds; limit for crosscorrelogram
crosscorr_tvec = collect(-crosscorr_lim-delta_crosscorr/2: delta_crosscorr : crosscorr_lim+delta_crosscorr/2) # time bins for autocorrelogram
crosscorr = zeros(length(crosscorr_tvec)-1)
for i = 1:length(spiketrain_A)
    target_spike = spiketrain_A[i]
    for j = 2:length(crosscorr_tvec)
        shifted_train = spiketrain_B .- target_spike
        count = sum( (shifted_train.>crosscorr_tvec[j-1]) .& (shifted_train.<crosscorr_tvec[j]) )
        crosscorr[j-1] += count
    end
end

# Plot autocorrelogram
bar(crosscorr_tvec,crosscorr,label="",xlabel="A to B time lag (s)",ylabel="Cross correlation",grid=false)
