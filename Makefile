BOOK_DIR := predavanja
COURSE_SLUG := papvp
USERPAGES_REPO := git@github.com:ljupco-todorovski/ljupco-todorovski.github.io.git
USERPAGES_DIR := .userpages

.PHONY: book start clean publish

book:
	cd $(BOOK_DIR) && BASE_URL=/$(COURSE_SLUG) jupyter book build --html

start:
	cd $(BOOK_DIR) && jupyter book start

clean:
	cd $(BOOK_DIR) && jupyter book clean --all

publish:
	# Build static HTML for GitHub Pages (subpath deployment)
	cd $(BOOK_DIR) && jupyter book clean --all
	cd $(BOOK_DIR) && BASE_URL=/$(COURSE_SLUG) jupyter book build --html

	# Take care of the static files that accompany the content
	# mkdir -p $(BOOK_DIR)/_build/html/materiali
	# cp -f materiali/preisci.py $(BOOK_DIR)/_build/html/materiali
	# cp -f materiali/romania-*.csv $(BOOK_DIR)/_build/html/materiali
	# cp -f materiali/minimax-primer.png $(BOOK_DIR)/_build/html/materiali
	# cp -f materiali/alphabeta-primer.png $(BOOK_DIR)/_build/html/materiali
	# cp -f materiali/pristranskost-varianca-kompromis.png $(BOOK_DIR)/_build/html/materiali
	# cp -f materiali/pristranskost-varianca-tarca.png $(BOOK_DIR)/_build/html/materiali

	# Clone/update the user pages repo
	if [ ! -d "$(USERPAGES_DIR)/.git" ]; then \
		git clone $(USERPAGES_REPO) $(USERPAGES_DIR); \
	else \
		cd $(USERPAGES_DIR) && git pull --ff-only; \
	fi

	# Ensure .nojekyll exists (so folders like _assets/ are served)
	touch $(USERPAGES_DIR)/.nojekyll

	# Replace only the course folder (keeps other courses, e.g., /uui/)
	rm -rf $(USERPAGES_DIR)/$(COURSE_SLUG)
	mkdir -p $(USERPAGES_DIR)/$(COURSE_SLUG)
	rsync -av --delete $(BOOK_DIR)/_build/html/ $(USERPAGES_DIR)/$(COURSE_SLUG)/

	# Commit & push if there are changes
	cd $(USERPAGES_DIR) && \
		git add .nojekyll $(COURSE_SLUG) && \
		(git diff --cached --quiet || git commit -m "Update $(COURSE_SLUG) notes") && \
		git push
