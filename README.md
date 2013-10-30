# jira-remotelinker

A small command line tool for creating bidirectional remote links between JIRA instances through REST API calls.

## Usage

To use this tool, you will need to first connect your JIRA instances through [Application Links](https://confluence.atlassian.com/display/JIRA/Linking+to+Another+Application).
Then, create a YAML file describing the JIRA instances along with the links that connect them:

```yaml
public:
  base_url: 'https://jira6-public.example.com'
  name: 'Name of Application Link for Private instance'
  uuid: 'UUID of Application Link for Private instance'
  username: 'some user with create link permissions'
  password: 'password for user'
private:
  base_url: 'https://jira6-private.example.com'
  name: 'Name of Application Link for Public instance'
  uuid: 'UUID of Application Link for Public instance'
  username: 'some user with create link permissions'
  password: 'password for user'
```

Discovering the UUID associated with an application link is a bit tricky as this value does not appear to be publicly exposed.
However, the UUID is required for the creation of fully functioning cross-application links.
One way to extract the `uuid` associated with an application link is through the following database query (tested on JIRA 6.1.x backed by PostgreSQL):

```sql
/* Retrieve Application Link names and UUIDs From JIRA
 * Based on a query described in the Atlassian troubleshooting docs:
 *
 *   https://confluence.atlassian.com/display/JIRAKB/How+to+remove+Application+link+directly+through+database
 *
 */
SELECT
  propertystring.propertyvalue AS "name",
  SUBSTR(propertyentry.property_key,16,36) AS "uuid"
FROM
  propertyentry, propertystring
WHERE
  propertyentry.id = propertystring.id AND
  propertyentry.property_key like 'applinks.admin%name';

```

The second piece of required input is a CSV file containing the issue link data.
The required pieces of data are:

  - **source_instance:** The name of a JIRA instance defined in the YAML configuration file.
  - **source_id:** The global numeric id of the source ticket.
  - **source_key:** The project-specific id of the source ticket (i.e. "PUB-2").
  - **source_relation:** The relationship between the source ticket and the target ticket (i.e. "blocks").
  - **target_instance:** The name of a JIRA instance defined in the YAML configuration file.
  - **target_id:** The global numeric id of the target ticket.
  - **target_key:** The project-specific id of the target ticket (i.e. "PRIV-20").
  - **target_relation:** The relationship between the target ticket and the source ticket (i.e. "blocked by").

These fields are laid in a CSV file in the following order:

source_instance | source_id | source_key | source_relation | target_instance | target_id | target_key | target_relation
--- | --- | --- | --- | --- | --- | --- | ---
public | 10020 | PUB-2 | blocks | private | 11234 | PRIV-20 | blocked by
public | 10042 | PUB-7 | duplicated by | private | 11555 | PRIV-42 | duplicates


Once the YAML and CSV files have been created, the tool can be invoked:

    jira-remotelinker jira_instances.yaml link_data.csv

---
<p align="center">
  <img src="http://i.imgur.com/iDFAxAM.jpg" />
</p>
