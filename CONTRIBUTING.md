# How to contribute to Eclipse IoT Packages

Thank you for your interest in contributing to IoT Packages.
We welcome your additions to this project.

## Eclipse Contributor Agreement

Before your contribution can be accepted by the project team contributors must
electronically sign the Eclipse Contributor Agreement (ECA).

* https://accounts.eclipse.org/user/eca

Commits that are provided by non-committers must have a Signed-off-by field in
the footer indicating that the author is aware of the terms by which the
contribution has been provided to the project. The non-committer must
additionally have an Eclipse Foundation account and must have a signed Eclipse
Contributor Agreement (ECA) on file.

For more information, please see the Eclipse Committer Handbook:
https://www.eclipse.org/projects/handbook/#resources-commit

## Making your Changes

* Fork the repository on GitHub
* Create a new branch for your changes
* Make your changes
* When you create new files make sure you include a proper license header at the top of the file (see License Header section below).
* Commit your changes into that branch
* Use descriptive and meaningful commit messages. In particular, start the first line of the commit message with the
  number of the issue that the commit addresses, e.g. `[#9865] Add token based authentication.`
* Squash multiple commits that are related to each other semantically into a single one
* Make sure you use the `-s` flag when committing as explained above
* Push your changes to your branch in your forked repository

## Submitting the Changes

Submit a pull request via the normal GitHub UI.

## After Submitting

* Do not use your branch for any other development, otherwise further changes that you make will be visible in the PR.

## License Header

Please make sure any file you newly create contains a proper license header like this:

````
/**
 * Copyright (c) 2020 Contributors to the Eclipse Foundation
 *
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * https://www.eclipse.org/legal/epl-2.0
 *
 * SPDX-License-Identifier: EPL-2.0
 */
````
You should, of course, adapt this header to use the specific mechanism for comments pertaining to the type of file you create, e.g. using something like

````
<!--
 Copyright (c) 2020 Contributors to the Eclipse Foundation

 See the NOTICE file(s) distributed with this work for additional
 information regarding copyright ownership.

 This program and the accompanying materials are made available under the
 terms of the Eclipse Public License 2.0 which is available at
 https://www.eclipse.org/legal/epl-2.0

 SPDX-License-Identifier: EPL-2.0
-->
````

when adding an XML file.
