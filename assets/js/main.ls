<- $

# Globals variables
# 	An array containing objects with information about the heroes.
heroes = []

# Our filters object will contain an array of values for each filter

# Example:
# filters = {
# 		"theme" = ["Apple","Sony"],
#		"main-weapons" = [16]
#	}
filters = {}


#	Event handlers for frontend navigation

#	Checkbox filtering

checkboxes = $ '.all-heroes input[type=checkbox]'

checkboxes.click(->

	infoName = ($ @).attr 'name'

	# When a checkbox is checked we need to write that in the filters object;
	if ($ @).is ':checked'

		# If the filter for this info isn't created yet - do it.
		filters[infoName] = [] if not (filters[infoName] && filters[infoName].length)

		#	Push values into the chosen filter array
		filters[infoName].push ($ @).val!

		# Change the url hash;
		createQueryHash filters

	# When a checkbox is unchecked we need to remove its value from the filters object.
	if not ($ @).is ':checked'

		if filters[infoName] && filters[infoName].length && (filters[infoName].indexOf ($ @).val!) isnt -1

			# Find the checkbox value in the corresponding array inside the filters object.
			index = filters[infoName].indexOf ($ @).val!

			# Remove it.
			filters[infoName].splice index, 1

			# If it was the last remaining value for this info,
			# delete the whole array.
			delete! filters[infoName] if not filters[infoName].length

		# Change the url hash;
		createQueryHash filters)

# When the "Clear all filters" button is pressed change the hash to '#' (go to the home page)
$ '.filters button' .click((e) ->
	e.preventDefault!
	window.location.hash = '#')

# Single hero page buttons

singleHeroPage = $ '.single-hero'

singleHeroPage.on 'click', (e) ->

	if singleHeroPage.hasClass 'visible'

		clicked = $ e.target

		# Change the url hash with the last used filters, and If the close button or the background are clicked go to the previous page.
		createQueryHash filters if (clicked.hasClass 'close') || clicked.hasClass 'overlay'

# These are called on page load

# Get data about our heroes from heroes.json.
$.getJSON 'heroes.json', (data) ->

	# Write the data into our global variable.
	heroes := data;

	# Call a function to create HTML for all the heroes.
	generateAllHeroesHTML heroes

	# Manually trigger a hashchange to start the app.
	$ window .trigger 'hashchange'

render = (url) ->

	# Get the keyword from the url.
	temp = (url.split '/').0

	# Hide whatever page is currently shown.
	$ '.main-content .page' .removeClass 'visible'


	map = {

		# The "Homepage".
		'': ->

			# Clear the filters object, uncheck all checkboxes, show all the heroes
			filters = {}
			checkboxes.prop 'checked',false
			renderHeroesPage heroes

		# Single Heroes page.
		'#hero': ->

			# Get the index of which hero we want to show and call the appropriate function.
			index = (url.split '#hero/').1.trim!

			renderSingleHeroPage index,heroes

		# Page with filtered heroes
		'#filter': ->

			# Grab the string after the '#filter/' keyword. Call the filtering function.
			filterNames = (url.split '#filter/').1.trim!

			# Try and parse the filters object from the query string.
			try
				filters = JSON.parse filterNames

			# If it isn't a valid json, go back to homepage ( the rest of the code won't be executed ).
			catch err
				window.location.hash = '#'
				return
			renderFilterResults filters, heroes
	}

	# Execute the needed function depending on the url keyword (stored in temp).
	# If the keyword isn't listed in the above - render the error page.
	if map[temp] then map[temp]! else renderErrorPage!

# An event handler with calls the render function on every hashchange.
# The render function will show the appropriate content of out page.
$ window .on 'hashchange', -> render window.location.hash


# Navigation



# This function is called only once - on page load.
# It fills up the heroes list and the filters via a handlebars template.
# It recieves one parameter - the data we took from heroes.json.
generateAllHeroesHTML = (data) ->

	list = $ '.all-heroes .heroes-list'
	themelist = $ '.theme'
	mainlist = $ '.main'
	sublist = $ '.sub'
	draclist = $ '.drac'
	appearanceslist = $ '.appearances'

	theTemplateScript = $ '#heroes-template' .html!
	theThemeScript = $ '#theme-filter' .html!
	theMainScript = $ '#main-filter' .html!
	theSubScript = $ '#sub-filter' .html!
	theDracScript = $ '#drac-filter' .html!
	theAppearancesScript = $ '#appearances-filter' .html!
	
	# Compile the template​s
	theTemplate = Handlebars.compile theTemplateScript
	theTheme = Handlebars.compile theThemeScript
	theMain = Handlebars.compile theMainScript
	theSub = Handlebars.compile theSubScript
	theDrac = Handlebars.compile theDracScript
	theAppearances = Handlebars.compile theAppearancesScript
	
	list.append theTemplate data
	themelist.append theTheme data
	mainlist.append theMain data
	sublist.append theSub data
	draclist.append theDrac data
	appearanceslist.append theAppearances data

	# Each hero has a data-index attribute.
	# On click change the url hash to open up a preview for this hero only.
	# Remember: every hashchange triggers the render function.
	list.find 'li' .on 'click', (e) ->
		e.preventDefault!

		heroIndex = $ this .data 'index'

		window.location.hash = 'hero/' + heroIndex

# This function receives an object containing all the heroes we want to show.
renderHeroesPage = (data) ->

	page = $ '.all-heroes'
	allHeroes = $ '.all-heroes .heroes-list > li'

	# Hide all the heroes in the heroes list.
	# allHeroes.addClass 'hidden' 

	# Iterate over all of the heroes.
	# If their ID is somewhere in the data object remove the hidden class to reveal them.
	allHeroes.each(->
		
		data.forEach ((item) -> ($ @).removeClass 'hidden' if (($ @).data 'index') is item.id))				

	# Show the page itself.
	# (the render function hides all pages so we need to show the one we want).
	page.addClass 'visible'

# Opens up a preview for one of the heroes.
# Its parameters are an index from the hash and the heroes object.
renderSingleHeroPage = (index, data) ->

	page = $ '.single-hero'
	container = $ '.preview-large'

	# Find the wanted hero by iterating the data object and searching for the chosen index.
	if data.length
		data.forEach((item) ->
			if item.id ~= index
				# Populate '.preview-large' with the chosen hero's data.
				container.find 'h3' .text item.name
				container.find 'img' .attr 'src', item.image.large
				container.find 'p' .text item.description)

	# Show the page.
	page.addClass 'visible'

# Find and render the filtered data results. Arguments are:
# filters - our global variable - the object with arrays about what we are searching for.
# heroes - an object with the full heroes list (from heroes.json).
renderFilterResults = (filters, heroes) ->

	# This array contains all the possible filter criteria.
	criteria = [
		'theme'
		'main-weapons'
		'sub-weapons'
		'dracula-defeats'
		'appearances-canon'
	]
	results = []
	isFiltered = false

	# Uncheck all the checkboxes.
	# We will be checking them again one by one.
	checkboxes.prop 'checked', false


	criteria.forEach((c) ->

		# Check if each of the possible filter criteria is actually in the filters object.
		if filters[c] && filters[c].length

			# After we've filtered the heroes once, we want to keep filtering them.
			# That's why we make the object we search in (heroes) to equal the one with the results.
			# Then the results array is cleared, so it can be filled with the newly filtered data.
			if isFiltered
				heroes = results

			# In these nested 'for loops' we will iterate over the filters and the heroes
			# and check if they contain the same values (the ones we are filtering by).

			# Iterate over the entries inside filters.criteria (remember each criteria contains an array).
			filters[c].forEach((filter) ->

				# Iterate over the heroes.
				heroes.forEach((item) ->

					# If the hero has the same info value as the one in the filter
					# push it inside the results array and mark the isFiltered flag true.

					if typeof item.info[c] ~= 'number'
						if item.info[c] ~= filter
							results.push item
							isFiltered := true

					if typeof item.info[c] ~= 'string'
						if not ((item.info[c].toLowerCase!.indexOf filter) ~= -1)
							results.push item
							isFiltered := true)

				# Here we can make the checkboxes representing the filters true,
				# keeping the app up to date.
				($ 'input[name='+c+'][value='+filter+']').prop 'checked', true if c && filter))

	# Call the renderHeroesPage.
	# As it's argument give the object with filtered heroes.
	renderHeroesPage results

# Shows the error page.
renderErrorPage = ->
	page = $ '.error'
	page.addClass 'visible'

# Get the filters object, turn it into a string and write it into the hash.
createQueryHash = (filters) ->

	# Here we check if filters isn't empty, then stringify the object via JSON.stringify and write it after the '#filter' keyword.
	# Else, if it's empty change the hash to '#' (the homepage).

	if not $.isEmptyObject filters then	window.location.hash = '#filter/' + JSON.stringify filters else	window.location.hash = '#'
