# Attack Vectors

This is intended to walk through the likely vectors of attack on Beacon, and various methods that attempt to thwart those attacks.

## Attack via malicious malformed network requests

One common way to attack a Rails application is by providing unexpected parameters to controller actions, or unexpected values to expected parameters.

Useful methods for study would include fuzz-testing to provide randomized bad values to controllers.

## Compromise of the Host Machine

It must be assumed that attackers will wish to compromise the host that one or more Beacon instances run on. Multiple types of compromise are possible.

### Superuser Account Compromise

This magnitude of compromise cannot be reasonably defended. If there is a superuser account compromise, it is capable of reading any possible secret configuration from any user, and even reading the memory of Beacon's process. There is no app-level attempt to defend against this scenario, as it cannot be defended at that level.

The best way to defend against this level of compromise is to limit the credentials the app server needs and uses. For example, there may be separate credentials for writing backups versus reading/editing them; there may also be multiple, limited sets of database credentials for different operations (e.g. separate database migration credentials which are not normally present on the application server.)

### Rails Server Compromise

If a Rails application server process is compromised, it will have the application server secrets in memory. This is effectively as bad as a superuser account compromise on the application server.

Similarly, compromise of the Unix user under which the application server runs is effectively equivalent to the compromise of the Rails server itself - in this case, no defense is currently possible.

It is useful to do as little as possible as the superuser and/or the web server's Unix account user to make these compromises difficult.

### Beacon Account Compromise

One important form of compromise is the compromise of a single non-administrator account in Beacon itself. While this would clearly compromise all data belonging to that account, it should not compromise other data belonging to other accounts.

The use of randomized UUIDs for IDs in all tables prevents monitoring of IDs from allowing estimation of the number of different items being created in different tables. Some estimate of this may still possible by measuring query times, which will slow down as more items are added. But some level of timing attacks cannot be prevented in general, especially with a compromised account in the same application. UUIDs provide an excellent first line of defense.

### Other Account Compromise

It is possible that another account on the same host might be compromised, or a daemon with some permissions on the host. The obvious forms of compromise here are if such an account or daemon could read files in /tmp or other globally readable files.

In the future, when the hosting configuration is final, it should be audited to determine what users can read the database's backing files and/or connect to the local database instance(s). It may be worth considering some form of whole-database encryption. It would definitely be worth making sure that no database server runs on the same host as an application server.

This case needs more research, particularly as new hosting and operations are finalized.

### Database Account/Connection Compromise

If a database account is compromised, significant information can be read from it. Database accounts can have limited permissions, but cannot easily enforce application-level permissions or log suspicious activity.

Mitigations: foreign keys in the database are encrypted to prevent easy linking of reports, issues, etc. with reporters. Each key has an individual, specific salt, preventing different encrypted links to the same ID from having an identical bit pattern.
