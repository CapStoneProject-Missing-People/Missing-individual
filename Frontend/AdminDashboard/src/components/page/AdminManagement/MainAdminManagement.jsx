import React from 'react'
import Title from '../../pagename/Title'
import TableComponentPresentation from './Table/TableComponentPresentation'

export default function MainUserManagement() {
  return (
    <div className="h-96">
      <Title pageName="Admin Management" />
      <TableComponentPresentation/>
    </div>
  )
}


