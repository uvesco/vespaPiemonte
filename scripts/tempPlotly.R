# # Create a basic plotly object with the first set of y-variables


p <- plot_ly(data = cattureTF, x = ~AnnoMeseMedioCattura, y = ~get(taxa$colonne[1]), color =  ~tipo, colors = c("red", "green"), type ="bar")

# # Add traces for the remaining y-variables

p <- p %>% add_trace(y = ~Vespa_crabro_tot, visible = FALSE)
p <- p %>% add_trace(y = ~altri_Vespidae, visible = FALSE)
p <- p %>% add_trace(y = ~Apis.mellifera, visible = FALSE)
p <- p %>% add_trace(y = ~Bombus.sp., visible = FALSE)
p <- p %>% add_trace(y = ~Altri_Anthophila, visible = FALSE)
p <- p %>% add_trace(y = ~Lepidoptera, visible = FALSE)
p <- p %>% add_trace(y = ~Sirphidae, visible = FALSE)
p <- p %>% add_trace(y = ~Diptera, visible = FALSE)
p <- p %>% add_trace(y = ~Altro, visible = FALSE)


# q: can you create add_trace without a loop?
# a: yes, you can create add_trace without a loop
# q: can you code it for me?
# 




# p <- layout(p, barmode = "stack")
# p
dropDown <- list()
for(i in 1:nrow(taxa)){
  visibilities <- rep(FALSE, nrow(taxa))
  visibilities[i] <- TRUE
  visibilities <- as.vector(matrix(rep(visibilities, 2), 2, nrow(taxa), byrow = T ))
  dropDown[[i]] <- list(
    method = "update",
    args = list(
      list(visible = visibilities),
      list(title = taxa$etichette[i])
    ),
    label = taxa$etichette[i]
  )
}

# Add layout to include the dropdown menu

p <- p %>%
  layout(
    xaxis = list(title = "mesi"),  # Custom x-axis label
    yaxis = list(title = "controlli"),   # Custom y-axis label
    updatemenus = list(
      list(
        type = "dropdown",
        x = 0.2,
        y = 1.1,
        showactive = TRUE,
        buttons = dropDown
      )
    ),
    barmode = "stack"
  )

p
