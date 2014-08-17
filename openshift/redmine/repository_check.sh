#!/bin/bash

cd $OPENSHIFT_REPO_DIR
rake redmine:fetch_changesets RAILS_ENV=production

