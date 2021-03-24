let s = React.string

open Belt

type state = {posts: array<Post.t>, forDeletion: Map.String.t<Js.Global.timeoutId>}

type action =
  | DeleteLater(Post.t, Js.Global.timeoutId)
  | DeleteAbort(Post.t)
  | DeleteNow(Post.t)

let reducer = (state, action) =>
  switch action {
  | DeleteLater(post, timeoutId) => state
  | DeleteAbort(post) => state
  | DeleteNow(post) => state
  }

let initialState = {posts: Post.examples, forDeletion: Map.String.empty}

type contentType =
  | Warning
  | Excerpt

let toggleContentType = (type_: contentType) => {
  switch(type_){
    | Warning => Excerpt
    | Excerpt => Warning
  }
}

/*
id: string,
title: string,
author: string,
text: array<string>,
*/

module Warning = {
  @react.component
  let make = (~post: Post.t) => {

    let restoreBtnClass = "mr-4 mt-4 bg-yellow-500 hover:bg-yellow-900 text-white py-2 px-4"
    let deleteBtnClass = "mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4"

    <div className="relative bg-yellow-100 px-8 py-4 mb-4 h-40">
      <p className="text-center white mb-1">
        {
          `This post from ${post.title} by ${post.author} will be permanently removed in 10 seconds.`
          ->React.string
        }
      </p>
      <div className="flex justify-center">
        <button className=restoreBtnClass> {s("Restore")} </button>
        <button className=deleteBtnClass> {s("Delete Immediately")} </button>
      </div>
      <div className="bg-red-500 h-2 w-full absolute top-0 left-0 progress"></div>
    </div>
  }
}

module Excerpt = {
  @react.component
  let make = (~post: Post.t, ~removeFunc) => {
    let divClass = "bg-green-700 hover:bg-green-900 text-gray-300 hover:text-gray-100 px-8 py-4 mb-4"
    let buttonClass = "mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4"



    <div className=divClass>
      <h2 className="text-2xl mb-1">{post.title->s}</h2>
      <h3 className="mb-4">{post.author->s}</h3>
      {
        post.text
        ->Belt.Array.map( cont => {
          <p className="mb-1 text-sm"> {cont->s} </p>
        })
        ->React.array
      }
      <button className=buttonClass onClick={ removeFunc }>
        {s("Remove this post")}
      </button>
    </div>
  }
}

let showWarning = (type_: contentType) => {
  switch(type_){
    | Warning => true
    | Excerpt => false
  }
}

module Post = {
  @react.component
  let make = (~post: Post.t ) => {
    let (content, setContent) = React.useState(() => Excerpt)
    if showWarning(content){
      <Warning post=post />
    } else {
      <Excerpt post=post removeFunc={ _ => setContent( _ => Warning)} />
    }
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)

  <div className="max-w-3xl mx-auto mt-8 relative">
  {
    state.posts
    ->Belt.Array.map( postContent => {
      <Post key=postContent.id post=postContent />
    })
    ->React.array
  }
  </div>
}
