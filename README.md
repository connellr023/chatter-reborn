# <img style="width: 300px" src="web/public/logo.png">

> A massively concurrent chat application designed for real-time, one-on-one conversations.

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB)
![Erlang](https://img.shields.io/badge/Erlang+Gleam-white.svg?style=for-the-badge&logo=erlang&logoColor=a90533)
![API CI Status](https://img.shields.io/github/actions/workflow/status/connellr023/chatter-reborn/api_ci.yml?style=for-the-badge&logo=erlang)

<br />

## Deployment

This demonstration project is deployed **On Render** ![here](https://chatter-5dkr.onrender.com/).

## Overview

This project is a re-implementation of a previous version I developed with **Node.js**, now using **Gleam** (compiled to **Erlang**). The underlying architecture has been entirely redesigned, as described below.

## Why Re-Implement in Gleam?

I chose to re-implement this project in **Gleam** for several reasons:

- **Learning Functional Programming**: I wanted to start learning functional programming, and Gleam provides a great opportunity to do so.
- **Type Safety**: Type safety is crucial for me, and Gleam offers strong type guarantees, unlike the dynamically typed **Erlang** and **Elixir**.
- **Familiar Syntax**: As someone who enjoys the **Rust** programming language, I found Gleam’s syntax familiar, which eased my transition into functional programming.
- **Simplicity and Concurrency**: Gleam is simple to pick up and excels at creating concurrent applications. It outperforms **Node.js** (single-threaded) and **Rust** (with its complex async programming model) in this regard.

## Chatter API Actor Model

![Actor Model Diagram](public/diagram.png)

In **Erlang**-based languages, concurrent applications typically use the **Actor Model**. Here’s how it works:

- **Actors as Processes**: Each actor is an independent process with its own thread and memory resources, managed by the **BEAM VM**.
- **Mailboxes and Messaging**: Actors communicate through mailboxes. In **Gleam**, mailboxes are addressed via a *subject* (similar to *PID* in **Erlang** and **Elixir**).
- **Concurrency Without Shared Memory**: Since actors do not share memory, there is no need for concurrency primitives like *Mutexes*, reducing complexity and potential issues.
- **Encapsulation and Scalability**: The Actor Model inherently provides separation of concerns by encapsulating logic within each actor, enabling scalable and reliable system development.

## Conclusion

This project demonstrates the advantages of using **Gleam** for building concurrent applications. It showcases the simplicity, type safety, and powerful concurrency model that **Gleam** offers.

---

This version aims to be clear and concise, emphasizing the benefits of using Gleam and explaining the Actor Model in a straightforward manner.

<br />
<br />

<div align="center">
  Developed and Tested by <b>Connell Reffo</b> in <b>2024</b>
</div>
