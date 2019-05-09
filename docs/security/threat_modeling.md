# Threat Modeling

Threat Modeling is (roughly) the discipline of imagining who might wish to attack you and what they want rather than starting from *how* they might do so. You can do both, of course.

The [EFF's list of threat modeling questions](https://ssd.eff.org/en/module/your-security-plan) are a good starting point (link credit: @cotarg).

## Ambient Network Malicious Actors

Frequent, low-intensity attacks with no customization come from petty criminals, spam botnets and other actors with little or no specific interest in Beacon.

In this case, the intent will be low-level compromise of the host machine. Normally this will occur via OS services rather than anything specific to Beacon itself.

In general, Beacon is well-architected to defend this scenario. An outer static-site wrapper with only a single login URL is an excellent defense. As with nearly any application, "expose very little surface area" is the right approach.

The accompanying operations strategy is to run as few additional services as possible and to make sure they aren't easily accessible from outside the host.

Overall, this category is likely to be frequent but will not normally require human intervention. As a percentage of attacks, by far the largest mitigation is "don't have a WordPress login URL," followed closely by "don't run PHP."

## Disgruntled Actors

Subjects of unfavorable reports and their online allies will likely be a frequent source of attacks. Some will be effectively indistinguishable from ambient malicious actors (above), while others will more directly target the Beacon application itself.

Likely goals include destruction or release (copying) of information from Beacon.

We should expect most attacks at this level to be mitigated by the same "gated" static/dynamic structure with a login URL in between. These actors are likely to probe in more detail, and Beacon developers should expect to need to harden the login URL and authentication against them.

Actors at this level will not normally be able to break encryption, nor will they have significant social engineering capability. In some cases they may have access to a Beacon account. This could occur by working at a participating company, by compromise of a Beacon accountholder's credentials or by social engineering.

Primary defenses at this level look like multitenancy - prevent reading data between users or organizations, and make sure that the application automatically scopes information to the narrowest reasonable level.

Other classes of attacker at roughly this level include journalists, busybodies and general shit-stirrers - people who would like to find out, destroy or publicize unflattering information but don't have a large budget or a lot of expertise with which to do so.

The frequency of attacks at this level will rise rapidly when Beacon gets publicity.

## Profit-Seeking Actors

If successful, Beacon will contain a substantial amount of, in effect, blackmail information. Another actor could use or sell such information, making it potentially profitable to steal.

This strongly suggests that in the future, Beacon production credentials should be evaluated in terms of how much information can be read from them. Similarly, administrator credentials should be given out extremely carefully.

Other than social-engineering compromise of production credentials, obvious attack methods are similar to previous categories. The primary difference in this class of attacker is that they must be assumed to have a budget.

Even at this level, we assume that these actors will *not* normally have an accomplice at the hosting company. In general, a hosting company will have a level of care and attention to security that will be hard for Beacon to match.

## Disgruntled Black-Hat Hackers and Security Professionals

Beacon is unusually likely to have problems from actors with a limited budget (perhaps a few thousand USD), but an unusual degree of computer security expertise.

Obvious methods of attack would include securing hosting with the same provider (e.g. EC2, Heroku) and finding ways to monitor insecure traffic, perform timing attacks, etc. Primary methods of defense would include maintaining encryption all the way to the application server, and (budget allowing) using dedicated networks, hosts, etc.

At this level it is unusual, but not *impossible* for the actor to have contacts at the hosting facility and some degree of access via those contacts. The mitigations are effectively similar, though - encryption on the application server which is not achieved via the hosting company, and dedicated hardware.

Since denial-of-service is much easier than direct compromise, other defenses might include use of a CDN and/or use of multiple hosting facilities and switching between them. Redundancy helps mitigate denial-of-service attacks but makes theft-of-information attacks easier.

## Other Actors

It is imaginable that even more capable actors (worst example: state-level actors) might be interested in compromising Beacon. However, this is not a primary threat concern because such attacks are so difficult to realistically mitigate.

In case of full-on attack by a maximally capable actor, defense is impossible. Recovery may be possible.

Methods to increase likelihood of recovery would include regular backups to multiple locations, and preventing edit/delete-capable credentials from being present on application servers.

# Cross-Cutting Concerns

## Configuration Information

As an open-source application, Beacon cannot easily prevent basic knowledge of its internals. Even basic hosting information (e.g. NGinX vs Apache) is unlikely to be worth the trouble of hiding. It's simply not viable to prevent
knowledge of common configuration of an open-source application discussed on public and semipublic forums.

