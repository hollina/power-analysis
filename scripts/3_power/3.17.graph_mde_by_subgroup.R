########################################################################################################
# Set package download location
options(repos = c(RSPM = "https://packagemanager.rstudio.com/all/latest"))

########################################################################################################
#  Clear memory
rm(list = ls())

#########################################################################################################
#  Load haven (to import data)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, tidyverse, ggpubr, ggrepel)

#########################################################################################################
#  Load data
data_to_plot <- fread("output/tables/partial_data_for_figure_in_r.csv")

#########################################################################################################
# Create County Level Plot
dd_data_to_plot <- data_to_plot %>% filter(spec_type == "dd" & geographic_level == "county")
ddd_data_to_plot <- data_to_plot %>% filter(spec_type == "ddd" & geographic_level == "county")

#########################################################################################################
# Plot DD MDE v First Stage. 
dd_mde_v_first_stage <- ggplot(data = subset(dd_data_to_plot, (!is.na(first_stage)) & (!is.na(MDE))), aes(x = first_stage, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DD with first-stage estimates" , y = "MDE", x = "First-stage (0-100%)")

dd_mde_v_first_stage


#########################################################################################################
# Plot DD MDE v Coef of Var. 
dd_mde_v_coef_of_var <- ggplot(data = subset(dd_data_to_plot, (!is.na(MDE)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "All DD specifications" , y = "MDE", x = "Coef. of variation for mortality rate")

dd_mde_v_coef_of_var

#########################################################################################################
# Plot DD First stage v Coef of var. 
dd_first_stage_v_coef_of_var <- ggplot(data = subset(dd_data_to_plot, (!is.na(first_stage)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = first_stage, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DD with first-stage estimates" , y = "First stage (0-100%)", x = "Coef. of variation for mortality rate")

dd_first_stage_v_coef_of_var

#########################################################################################################
# Plot DDD MDE v Coef of Var. 
ddd_mde_v_first_stage <- ggplot(data =  subset(ddd_data_to_plot, (!is.na(first_stage)) & (!is.na(MDE))), aes(x = first_stage, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DDD with first-stage estimates" , y = "MDE", x = "First Stage (0-100%)")

ddd_mde_v_first_stage

#########################################################################################################
# Plot DDD First stage v Coef of var. 
ddd_first_stage_v_coef_of_var <- ggplot(data = subset(ddd_data_to_plot, (!is.na(first_stage)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = first_stage, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DDD with first-stage estimates" , y = "First stage (0-100%)", x = "Coef. of variation for mortality rate")

ddd_first_stage_v_coef_of_var


#########################################################################################################
# Plot DDD MDE v First Stage. 
ddd_mde_v_coef_of_var <- ggplot(data = subset(ddd_data_to_plot, (!is.na(MDE)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "All DDD specifications" , y = "MDE", x = "Coef. of variation for mortality rate")

ddd_mde_v_coef_of_var

#########################################################################################################
#  Make overlaid leaded coef plot and cdf

CountyCombinedPlot <- ggarrange(dd_mde_v_first_stage, ddd_mde_v_first_stage,
                          dd_first_stage_v_coef_of_var, ddd_first_stage_v_coef_of_var,
                          dd_mde_v_coef_of_var, ddd_mde_v_coef_of_var,
                          nrow=3, ncol=2)
# Save
ggsave("output/figures/mde_by_subgroup_county.png",
       plot=CountyCombinedPlot,
       width = 8,
       height = 10.67,
       units = c("in"),
       dpi = 300)

#########################################################################################################
# Create County Level Plot
dd_data_to_plot <- data_to_plot %>% filter(spec_type == "dd" & geographic_level == "state")
ddd_data_to_plot <- data_to_plot %>% filter(spec_type == "ddd" & geographic_level == "state")

#########################################################################################################
# Plot DD MDE v First Stage. 
dd_mde_v_first_stage <- ggplot(data = subset(dd_data_to_plot, (!is.na(first_stage)) & (!is.na(MDE))), aes(x = first_stage, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DD with first-stage estimates" , y = "MDE", x = "First-stage (0-100%)")

dd_mde_v_first_stage


#########################################################################################################
# Plot DD MDE v Coef of Var. 
dd_mde_v_coef_of_var <- ggplot(data = subset(dd_data_to_plot, (!is.na(MDE)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "All DD specifications" , y = "MDE", x = "Coef. of variation for mortality rate")

dd_mde_v_coef_of_var

#########################################################################################################
# Plot DD First stage v Coef of var. 
dd_first_stage_v_coef_of_var <- ggplot(data = subset(dd_data_to_plot, (!is.na(first_stage)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = first_stage, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DD with first-stage estimates" , y = "First stage (0-100%)", x = "Coef. of variation for mortality rate")

dd_first_stage_v_coef_of_var

#########################################################################################################
# Plot DDD MDE v Coef of Var. 
ddd_mde_v_first_stage <- ggplot(data =  subset(ddd_data_to_plot, (!is.na(first_stage)) & (!is.na(MDE))), aes(x = first_stage, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DDD with first-stage estimates" , y = "MDE", x = "First Stage (0-100%)")

ddd_mde_v_first_stage

#########################################################################################################
# Plot DDD First stage v Coef of var. 
ddd_first_stage_v_coef_of_var <- ggplot(data = subset(ddd_data_to_plot, (!is.na(first_stage)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = first_stage, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "DDD with first-stage estimates" , y = "First stage (0-100%)", x = "Coef. of variation for mortality rate")

ddd_first_stage_v_coef_of_var


#########################################################################################################
# Plot DDD MDE v First Stage. 
ddd_mde_v_coef_of_var <- ggplot(data = subset(ddd_data_to_plot, (!is.na(MDE)) & (!is.na(coef_of_var))), aes(x = coef_of_var, y = MDE, size = N, label = label)) +
  geom_point(alpha = .5, color = "red") +
  geom_smooth(method = "lm") +
  geom_label_repel(size = 3) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "All DDD specifications" , y = "MDE", x = "Coef. of variation for mortality rate")

ddd_mde_v_coef_of_var

#########################################################################################################
#  Make overlaid leaded coef plot and cdf

StateCombinedPlot <- ggarrange(dd_mde_v_first_stage, ddd_mde_v_first_stage,
                                dd_first_stage_v_coef_of_var, ddd_first_stage_v_coef_of_var,
                               dd_mde_v_coef_of_var, ddd_mde_v_coef_of_var,
                                nrow=3, ncol=2)
# Save
ggsave("output/figures/mde_by_subgroup_state.png",
       plot=StateCombinedPlot,
       width = 8,
       height = 10.67,
       units = c("in"),
       dpi = 300)

#########################################################################################################
#  Make overlaid leaded coef plot and cdf

CombinedPlot <- ggarrange(StateCombinedPlot, CountyCombinedPlot,
                               nrow=1, ncol=2)

# Save
ggsave("output/figures/mde_by_subgroup.png",
       plot=CombinedPlot,
       width = 16,
       height = 10.67,
       units = c("in"),
       dpi = 300) 
