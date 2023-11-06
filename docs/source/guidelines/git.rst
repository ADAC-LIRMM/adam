===
Git
===

Branch Guidelines
=================

1. **Use feature branches**: By working in isolated branches, developers can
   implement and test new functionalities without affecting the ``main`` and
   ``dev`` branches.

2. **Branch out from dev**: Initiating new feature branches from ``dev``
   ensures that developers begin with the most recent version of the project,
   which simplifies the process of merging features back into dev.

3. **Rebase before pushes and pull requests**: Keeping your branch synchronized
   with the latest changes minimizes the risk of conflicts, ensuring
   straightforward pushes and pull request reviews.

4. **Don't push directely to dev and main**: Enforcing the use of pull requests
   for changes to the main and dev branches ensures that changes are reviewed
   before merging.

5. **Delete merged branches**: Deleting branches after they've been merged
   prevents the repository from being cluttered with obsolete branches,
   maintaining an organized list of the current efforts.