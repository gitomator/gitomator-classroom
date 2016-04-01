Just a quick "shopping list" of things that need to be created ...

 * A base class for all scripts/tasks:
   * In the constructor, set up
     * Services (e.g. hosting, git, ci)
     * Logger

 * A (virtual) subclass for scripts/tasks that take an assignment config and
   need to do something with each handout.
   * Subclasses will implement the hooks: before_all, process_handout, after_all.


 * Util classes
   * Name resolver - Assignment sandbox, handout-template, auto-marker, handouts.
   * Creating default services (e.g. based on environment variables).



Tasks related to an assignment
 * clone_handouts
 * publish_assignment
   * Create the handout-template, if it is not there.
   * Clone the handout-template.
   * Create each handout, if it is missing.
   * Push the local handout-template to each handout.
     * For repos with existing commits:
       * Check the SHA of the latest commit (to avoid unnecessary `git push`)
       * If pushing an update, make sure the `disable_ci` before the `git push`.
   * If using Travis - Synchronize Travis account with GitHub.
   * `enable_ci` for each handout.
   * Update the permissions for each handout.
 * collect_solutions
   * Merge a pull-request (and label it) for each handout.
   * Clone the handouts
 * Disable CI for all the handouts of an assignment
 * Publishing marks
   * Pushing the automarker outputs to a new branch.

Other tasks
 * register_students
 * Create the team repos
 * Push marks to team repos
