import React from 'react'
import Table1Presentation from './Table1Presentation'
import Title from '../../pagename/Title'
import TableComponentPresentation from './Table/TableComponentPresentation'

export default function MainUserManagement() {
  return (
    <div className=" h-96">
      <Title pageName="User Management" />
      <TableComponentPresentation/>
    </div>
  )
}


