module Ant.Button exposing
    ( Button
    , button, onClick, ButtonType(..), withType, withIcon, ButtonSize(..), disabled
    , toHtml
    )

{-| Button component

@docs Button


# Customizing the Button

@docs button, onClick, ButtonType, withType, withIcon, ButtonSize, disabled

@docs toHtml

-}

import Ant.Icons as Icon exposing (Icon)
import Ant.Internals.Palette exposing (primaryColor, primaryColorFaded, primaryColorStrong)
import Ant.Internals.Typography exposing (fontList, textColorRgba)
import Css exposing (..)
import Css.Animations as CA exposing (keyframes)
import Css.Global as CG
import Css.Transitions exposing (transition)
import Html exposing (Html)
import Html.Styled as H exposing (fromUnstyled, text, toUnstyled)
import Html.Styled.Attributes as A exposing (css)
import Html.Styled.Events as Events


{-| The type of the button
-}
type ButtonType
    = Primary
    | Default
    | Dashed
    | Text
    | Link


{-| Determines the size of the button
-}
type ButtonSize
    = Large
    | DefaultSize
    | Small


type alias Options msg =
    { type_ : ButtonType
    , size : ButtonSize
    , disabled : Bool
    , loading : Bool
    , href : Maybe String
    , onClick : Maybe msg
    , icon : Maybe (Icon msg)

    -- size : Size (Small, Medium, Large)
    -- etc etc
    }


defaultOptions : Options msg
defaultOptions =
    { type_ = Default
    , size = DefaultSize
    , disabled = False
    , loading = False
    , href = Nothing
    , onClick = Nothing
    , icon = Nothing
    }


{-| Represents a button component
-}
type Button msg
    = Button (Options msg) String


{-| Create a Button component.

    button "Click Me!"
        |> toHtml

-}
button : String -> Button msg
button label =
    Button defaultOptions label


{-| Change the default type of the Button

    button "submit"
        |> withType Dashed
        |> toHtml

-}
withType : ButtonType -> Button msg -> Button msg
withType buttonType (Button options label) =
    let
        newOptions =
            { options | type_ = buttonType }
    in
    Button newOptions label


{-| Add an icon to the button

    button "Search"
        |> withIcon searchOutlined
        |> toHtml

-}
withIcon : Icon msg -> Button msg -> Button msg
withIcon icon (Button options label) =
    let
        newOptions =
            { options | icon = Just icon }
    in
    Button newOptions label


{-| Make your button emit messages. By default, clicking a button does nothing.

    button "submit"
        |> onClick FinalCheckoutFormSubmitted
        |> toHtml

-}
onClick : msg -> Button msg -> Button msg
onClick msg (Button opts label) =
    let
        newOpts =
            { opts | onClick = Just msg }
    in
    Button newOpts label


{-| Make the button disabled. If you have a `onClick` event registered, it will not be fired.

    button "You can't click this"
        |> onClick Logout
        |> disabled True
        |> toHtml

-}
disabled : Bool -> Button msg -> Button msg
disabled disabled_ (Button opts label) =
    let
        newOpts =
            { opts | disabled = disabled_ }
    in
    Button newOpts label


textColor : Color
textColor =
    let
        { r, g, b, a } =
            textColorRgba
    in
    rgba r g b a


iconToHtml : Icon msg -> H.Html msg
iconToHtml icon =
    icon
        |> Icon.toHtml
        |> fromUnstyled


{-| Turn your Button into Html msg
-}
toHtml : Button msg -> Html msg
toHtml (Button options label) =
    let
        transitionDuration =
            350

        waveEffect =
            keyframes
                [ ( 100, [ CA.property "box-shadow" <| "0 0 0 " ++ primaryColorStrong ] )
                , ( 100, [ CA.property "box-shadow" <| "0 0 0 8px " ++ primaryColorStrong ] )
                , ( 100, [ CA.property "opacity" "0" ] )
                ]

        animatedBefore : ColorValue compatible -> Style
        animatedBefore color =
            before
                [ property "content" "\" \""
                , display block
                , position absolute
                , width (pct 100)
                , height (pct 100)
                , right (px 0)
                , left (px 0)
                , top (px 0)
                , bottom (px 0)
                , borderRadius (px 2)
                , backgroundColor color
                , boxShadow4 (px 0) (px 0) (px 0) (hex primaryColor)
                , opacity (num 0.2)
                , zIndex (int -1)
                , animationName waveEffect
                , animationDuration (sec 1.5)
                , property "animation-timing-function" "cubic-bezier(0.08, 0.82, 0.17, 1)"
                , property "animation-fill-mode" "forwards"
                , pointerEvents none
                ]

        animationStyle =
            CG.withClass "elm-antd__animated_before" <| [ position relative, animatedBefore (hex primaryColorStrong) ]

        antButtonBoxShadow =
            Css.boxShadow5 (px 0) (px 2) (px 0) (px 0) (Css.rgba 0 0 0 0.016)

        baseAttributes =
            [ borderRadius (px 2)
            , padding2 (px 4) (px 15)
            , fontFamilies fontList
            , borderWidth (px 1)
            , fontSize (px 14)
            , height (px 30)
            , outline none
            ]

        defaultButtonAttributes =
            [ color textColor
            , borderStyle solid
            , backgroundColor (hex "#fff")
            , borderColor <| rgb 217 217 217
            , antButtonBoxShadow
            , animationStyle
            , focus
                [ borderColor (hex primaryColorFaded)
                , color (hex primaryColorFaded)
                ]
            , hover
                [ borderColor (hex primaryColorFaded)
                , color (hex primaryColorFaded)
                ]
            , active
                [ borderColor (hex primaryColor)
                , color (hex primaryColor)
                ]
            , transition
                [ Css.Transitions.borderColor transitionDuration
                , Css.Transitions.color transitionDuration
                ]
            ]

        primaryButtonAttributes =
            [ color (hex "#fff")
            , borderStyle solid
            , backgroundColor (hex primaryColor)
            , borderColor (hex primaryColor)
            , antButtonBoxShadow
            , animationStyle
            , focus
                [ backgroundColor (hex primaryColorFaded)
                , borderColor (hex primaryColorFaded)
                ]
            , hover
                [ backgroundColor (hex primaryColorFaded)
                , borderColor (hex primaryColorFaded)
                ]
            , active
                [ backgroundColor (hex primaryColorStrong)
                , borderColor (hex primaryColorStrong)
                ]
            , transition
                [ Css.Transitions.backgroundColor transitionDuration
                , Css.Transitions.borderColor transitionDuration
                ]
            ]

        dashedButtonAttributes =
            defaultButtonAttributes
                ++ [ borderStyle dashed
                   , antButtonBoxShadow
                   , animationStyle
                   ]

        textButtonAttributes =
            [ color textColor
            , border zero
            , backgroundColor (hex "#fff")
            , hover
                [ backgroundColor (rgba 0 0 0 0.018) ]
            , transition
                [ Css.Transitions.backgroundColor transitionDuration ]
            ]

        linkButtonAttributes =
            [ color (hex primaryColor)
            , border zero
            , backgroundColor (hex "#fff")
            , hover
                [ color (hex primaryColorFaded) ]
            , transition
                [ Css.Transitions.color transitionDuration ]
            ]

        buttonTypeAttributes =
            case options.type_ of
                Default ->
                    defaultButtonAttributes

                Primary ->
                    primaryButtonAttributes

                Dashed ->
                    dashedButtonAttributes

                Text ->
                    textButtonAttributes

                Link ->
                    linkButtonAttributes

        combinedButtonStyles =
            if options.disabled then
                case options.type_ of
                    Default ->
                        baseAttributes
                            ++ [ borderColor <| rgb 217 217 217
                               , borderStyle solid
                               ]

                    Primary ->
                        baseAttributes
                            ++ [ borderColor <| rgb 217 217 217
                               , borderStyle solid
                               ]

                    Dashed ->
                        baseAttributes
                            ++ [ borderColor <| rgb 217 217 217
                               , borderStyle dashed
                               ]

                    Text ->
                        baseAttributes
                            ++ [ border zero
                               , backgroundColor transparent
                               ]

                    _ ->
                        baseAttributes

            else
                baseAttributes ++ buttonTypeAttributes

        cursorHoverStyles =
            if options.disabled then
                hover [ cursor notAllowed ]

            else
                hover [ cursor pointer ]

        attributes =
            let
                commonAttributes =
                    [ A.class "elm-antd__animated_btn"
                    , A.disabled options.disabled
                    , css <| cursorHoverStyles :: combinedButtonStyles
                    ]
            in
            case options.onClick of
                Just msg ->
                    Events.onClick msg :: commonAttributes

                Nothing ->
                    commonAttributes

        iconContent =
            case options.icon of
                Nothing ->
                    H.span [] []

                Just icon ->
                    H.span
                        [ css
                            [ marginRight (px 8)
                            , position relative
                            , top (px 2)
                            ]
                        ]
                        [ iconToHtml icon ]
    in
    toUnstyled
        (H.button
            attributes
            [ iconContent
            , H.span [] [ text label ]
            ]
        )
