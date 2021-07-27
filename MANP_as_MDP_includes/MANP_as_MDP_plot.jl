plots = Plots.Plot{Plots.GRBackend}[]                               

for stat in for_statistics
    
    avgs_beta = running_average(stat.Dirichlet_mdp.statistics)
    avgs_best = running_average(stat.best_mdp.statistics)
    avgs_random = running_average(stat.random_mdp.statistics)
    
    p1 = plot(1:num_of_experiments,avgs_beta, 
        ylim = [0, maximum(stat.best_mdp.statistics.pages_seen_per_user)],
        label="Dirichlet policy",
        ylabel=" Running average\n of pages seen",
        title="$(stat.pages_num) pages, $(stat.pre_rounds_num) user for data generation",
        xlabel= "Users number",
        size=(800,300 * length(for_statistics)))
    
    plot!(p1, 1:num_of_experiments, label="Best policy", avgs_best)
    plot!(p1, 1:num_of_experiments, label="Random policy", avgs_random)
    push!(plots, p1)
   
end
# println(plots)
plot(plots...,layout=(length(plots),1))