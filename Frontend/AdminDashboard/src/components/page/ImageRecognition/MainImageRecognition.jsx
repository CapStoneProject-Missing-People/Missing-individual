import React from "react";
import PersonList from "./PersonList";
import Title from '../../pagename/Title'

export default function MainImageRecognition() {
    return (
      <div className="h-96">
        <Title pageName="Image Management"/>
        <PersonList/>
      </div>
    )
  }

