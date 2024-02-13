USERNAME1=$(shell users)
BRANCH_NAME=$(shell git branch | grep "*" | sed "s/^.//" | sed "s/^.//")

#======================================== GIT =========================================================================
git:
	git add .
	git reset -- .gitignore
	git commit -m "${BRANCH_NAME} --> ${USERNAME1} --> developing"
	git push origin ${BRANCH_NAME}
