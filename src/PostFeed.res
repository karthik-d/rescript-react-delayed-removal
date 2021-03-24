@val external window: {..} = "window"

let s = React.string

open Belt

type state = {posts: array<Post.t>, forDeletion: Map.String.t<Js.Global.timeoutId>}

type action =
  | DeleteLater(Post.t, Js.Global.timeoutId)
  | DeleteAbort(Post.t)
  | DeleteNow(Post.t)

let reducer = (state, action) =>
  switch action {
    | DeleteLater(post, timeoutId) => {
        {...state, forDeletion: state.forDeletion->Map.String.set(post.id, timeoutId) }
      }
    | DeleteAbort(post) => {
      window["clearTimeout"](state.forDeletion->Map.String.get(post.id))
      {...state, forDeletion: state.forDeletion->Map.String.remove(post.id) }
    }
    | DeleteNow(post) => {
      {...state, posts: Js.Array.filter((chPost: Post.t) => (chPost.id!=post.id), state.posts)}
      }
  }

let initialState = {posts: Post.examples, forDeletion: Map.String.empty}

type contentType =
  | Warning
  | Excerpt

  /*
  id: string,
  title: string,
  author: string,
  text: array<string>,
  */

module Excerpt = {
  @react.component
  let make = (~post: Post.t, ~dispatchFeed) => {
    let divClass = "bg-green-700 hover:bg-green-900 text-gray-300 hover:text-gray-100 px-8 py-4 mb-4"
    let buttonClass = "mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4"

    let initPostDelete = _ => {
      let timeoutId = window["setTimeout"](() => dispatchFeed(DeleteNow(post)), 10000)
      dispatchFeed(DeleteLater(post, timeoutId))
    }

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
      <button className=buttonClass onClick={initPostDelete}>
        {s("Remove this post")}
      </button>
    </div>
  }
}

module Warning = {
  @react.component
  let make = (~post: Post.t, ~dispatchFeed) => {

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
        <button className=restoreBtnClass onClick={ _ => DeleteAbort(post)->dispatchFeed }> {s("Restore")} </button>
        <button className=deleteBtnClass onClick={ _ => DeleteNow(post)->dispatchFeed}> {s("Delete Immediately")} </button>
      </div>
      <div className="bg-red-500 h-2 w-full absolute top-0 left-0 progress"></div>
    </div>
  }
}


@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)

  <div className="max-w-3xl mx-auto mt-8 relative">
  {
    state.posts
    ->Belt.Array.mapWithIndex( (idx: int, postContent: Post.t) => {
      if(state.forDeletion->Map.String.has(postContent.id)){
        <Warning key={`${postContent.id}.${Belt.Int.toString(idx)}`} post=postContent dispatchFeed=dispatch />
      } else {
        <Excerpt key={`${postContent.id}.${Belt.Int.toString(idx)}`} post=postContent dispatchFeed=dispatch />
      }
    })
    ->React.array
  }
  </div>
}
